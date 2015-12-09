worker_processes 4
timeout 5
preload_app true

before_fork do |_, _|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  ActiveRecord::Base.connection.disconnect! if defined? ActiveRecord::Base
end

after_fork do |_, _|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  ActiveRecord::Base.establish_connection if defined? ActiveRecord::Base
end
