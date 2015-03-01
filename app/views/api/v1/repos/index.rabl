collection :@repos
attributes  :id, :name, :language, :ssh_url, :html_url, :private, :active, :full_name
node(:stars) { |repo| repo.stargazers_count }
node(:language_color) { |repo| Languages::Language[repo.language].color rescue '#eaeaea' }
node(:has_yml) { |repo| repo.user ? repo.has_owl_yml? : nil }
node(:user) { |repo| repo.full_name.split("/").first }


