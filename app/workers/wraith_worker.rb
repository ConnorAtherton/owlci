require 'yaml'

class WraithWorker
  include Sidekiq::Worker

  def perform(id)
    puts 'Wraith Worker started: ', id

	# example use 
    puts make_config("http://www.google.com", "shots", { :home => "/" })

  end

  def make_config(url, output_dir_prefix, paths)
  	YAML.dump({
  		"browser" => {
  			'phantomjs' => 'phantomjs'
  		},
  		"snap_file" => "javascript/snap.js",
  		"directory" => output_dir_prefix,
  		"history_dir" => output_dir_prefix + "_history",
  		"domains" => {
  			"english" => url
  		},
  		"screen_widths" => [ 1024 ],
  		"paths" => paths.stringify_keys,
  		"fuzz" => "20%",
  		"mode" => "diffs_first",
  		"threshold" => 5
  	})
  end
end