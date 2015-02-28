collection :@repos
attributes :id, :name, :full_name, :language, :fork
node(:stars) { |repo| repo.stargazers_count }
node(:language_color) { |repo| Languages::Language[repo.language].color rescue '#d2d2d2' }
node(:status) {|r| 'false'}
