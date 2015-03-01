collection :@repos
attributes :name, :full_name, :language, :fork, :ssh_url, :html_url, :private
node(:stars) { |repo| repo.stargazers_count }
node(:language_color) { |repo| Languages::Language[repo.language].color rescue '#d2d2d2' }
node(:active) { |repo| repo.try(:active) || "false" }

