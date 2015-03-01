collection :@repos
attributes :name, :full_name, :language, :ssh_url, :html_url, :private, :active
node(:stars) { |repo| repo.stargazers_count }
node(:language_color) { |repo| Languages::Language[repo.language].color rescue '#eaeaea' }
node(:has_yml) { |repo| repo.user ? repo.has_owl_yml? : nil }


