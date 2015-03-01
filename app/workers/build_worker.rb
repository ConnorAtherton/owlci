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
    @build.set_state! :in_progress
    @paths = { home: "/", about: "/intl/en/about/" }
    begin
      @relative_build_dir = File.join("/", "public", "builds", @build.repo.full_name, @build.number.to_s, @build.id.to_s)
      @build_dir = File.join(Rails.root, @relative_build_dir)
      FileUtils.mkdir_p(@build_dir)
      Dir.chdir(@build_dir) do
        # Setup wraith
        FileUtils.cp(WRAITH_SNAP_JS, @build_dir)
        # Clone repo, setup owl and wraith
        clone_repo
        checkout_sha(@build.head_sha)
        setup_owl
        write_config("http://localhost:5100")
        # Start base code
        checkout_sha(@build.base_sha)
        run_app
        # Run wraith for baseline
        run_wraith("history")
        kill_app
        # Checkout changes in head
        checkout_sha(@build.head_sha)
        run_app
        # Run wraith with changes
        run_wraith("latest")
        kill_app
        @build.results = get_results
      end
      @build.set_state :finished
      raise BuildError.new("Failed to save build results") unless @build.save
    rescue Exception => e
      # FileUtils.rm_rf(@build_dir)
      @build.set_state! :failed
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

  def clone_repo
    unless system("git clone #{@build.head_ssh_url} ./code")
      # raise BuildError.new("Failed to clone repository")
    end
  end

  def checkout_sha sha
    Dir.chdir('code') do
      unless system("git checkout #{sha}")
        raise BuildError.new("Failed to checkout #{sha}")
      end
    end
  end

  def setup_owl
    @owl = YAML.load(File.open('code/.owl.yml').read)
    @paths = @owl["paths"]
    unless @paths.present? && @owl["start"].present?
      raise BuildError.new("Owl not correctly configured in repository")
    end
    (@owl["docker"] || {}).reverse_merge!({
      image: "ubuntu:latest",
      port: 80,
      volume: "/tmp/owlci"
    }).with_indifferent_access
  end

  def run_app
    # Good old harpoon vagrant config ;)
    if Rails.env.development?
      docker_base_path = "/home/core/share/owlci"
    else
      docker_base_path = Rails.root
    end
    Dir.chdir('code') do
      image = @owl["docker"]["image"]
      image = "#{image}:latest" unless image.include?(":")
      Docker::Image.create(fromImage: image)
      app_dir = File.join(docker_base_path, @relative_build_dir, 'code')
      @container = Docker::Container.create(
        "name" => "owlci-build",
        "Cmd" => ["bash", "-c", @owl["start"]],
        "Image" => image,
        "WorkingDir" => @owl["docker"]["volume"],
        "ExposedPorts" => {
          "#{@owl["docker"]["port"]}/tcp" => {}
        },
      )
      @container.start(
        "Binds" => ["#{app_dir}:#{@owl["docker"]["volume"]}"],
        "PortBindings" => { "#{@owl["docker"]["port"]}/tcp" => [{ "HostIp" => "0.0.0.0", "HostPort" => "5100" }] },
      )
    end
    # TODO delay for apps that take longer?
  end

  def kill_app
    return unless @container
    @container.delete(:force => true)
    @container = nil
  end

  def get_results
    # will change if we support multiple screen sizes
    file_prefix = "1024_phantomjs_"
    @paths.inject({}) do |res, (label, route)|
      shots = File.join("shots", label.to_s)
      thumbs = File.join("shots", "thumbnails", label.to_s)
      res.tap do |h|
        h[label] = {
          route: route,
          score: File.open(File.join(@build_dir, shots, "#{file_prefix}data.txt")).read.to_f,
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
