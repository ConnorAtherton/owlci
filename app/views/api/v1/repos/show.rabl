object :@repo
attributes :full_name, :language, :ssh_url, :html_url, :private
node(:active) { |repo| repo.try(:active) || "false" }
