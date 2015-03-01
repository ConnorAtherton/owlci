object :@repo
attributes :id, :full_name, :ssh_url, :html_url, :private
node(:active) { |_| true }
