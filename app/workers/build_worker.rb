require 'yaml'

class BuildWorker
  include Sidekiq::Worker

  WRAITH_SNAP_JS = File.join(Rails.root, "lib", "wraith", "javascript", "snap.js")
  WRAITH_BIN = "wraith"
  WRAITH_CONFIG = ".owlci.wraith.yaml"

  def perform(id)
    @build = Build.find(id)
    unless Build.find(id) && (@build.not_started? || @build.failed?)
      puts "#### Build not found, or not in a buildable state, #{id}"
      return
    end
    @build.update_attribute(:state, :in_progress)
    @paths = { home: "/", about: "/intl/en/about/" }
    begin
      @relative_build_dir = File.join("/", "public", "builds", @build.repo.full_name, @build.number.to_s)
      @build_dir = File.join(Rails.root, @relative_build_dir)
      FileUtils.mkdir_p(@build_dir)
      Dir.chdir(@build_dir) do
        write_config("http://www.google.com")
        FileUtils.cp(WRAITH_SNAP_JS, @build_dir)
        run_wraith("history")
        write_config("http://www.google.com")
        run_wraith("latest")
        @build.results = get_results
      end
      @build.state = :finished
      raise BuildError.new("Failed to save build results") unless @build.save
    rescue Exception => e
      @build.update_attribute(:state, :failed)
      raise e
    end
  end

  def write_config(url)
    File.open(WRAITH_CONFIG, "w") do |file|
    	file.write(YAML.dump({
    		"browser" => {
    			'phantomjs' => 'phantomjs'
    		},
    		"snap_file" => "snap.js",
    		"directory" => "shots",
    		"history_dir" => "shots_history",
    		"domains" => {
    			"build" => url
    		},
    		"screen_widths" => [1024],
    		"paths" => @paths.stringify_keys,
    		"fuzz" => "20%",
    		"mode" => "diffs_first",
    		"threshold" => 5
    	}))
    end
  end

  def run_wraith(cmd)
    unless output = `#{WRAITH_BIN} #{cmd} #{WRAITH_CONFIG}`
      # Hack because wraith returns non-zero exit status if the build "fails"
      # We only care if the command fails
      raise BuildError.new("wraith command failed") unless output =~ /Failures detected/
    end
  end

  def get_results
    # will change if we support multiple screen sizes
    file_prefix = "1024_phantomjs_"
    @paths.inject({}) do |res, (label, _)|
      shots = File.join("shots", label.to_s)
      thumbs = File.join("shots", "thumbnails", label.to_s)
      res.tap do |h|
        h[label] = {
          score: File.open(File.join(@build_dir, shots, "#{file_prefix}data.txt")).read,
          shots_path: File.join(@relative_build_dir, shots),
          thumbs_path: File.join(@relative_build_dir, thumbs),
          head: "#{file_prefix}build_latest.png",
          base: "#{file_prefix}build.png",
          diff: "#{file_prefix}diff.png"
        }
      end
    end
  end

end

class BuildError < StandardError; end
