namespace :setup do
  desc 'Symlinks config files for Nginx.'
  task :symlink_config do
    on roles(:app) do
      execute 'sudo rm -f /etc/nginx/sites-enabled/default'
      execute "sudo ln -nfs #{current_dir}/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}"
    end
  end
end
