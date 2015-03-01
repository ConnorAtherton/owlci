class AddStarsAndLanguageToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :stargazers_count, :int
    add_column :repos, :language, :string
    change_column :repos, :active, :boolean , default: true
  end
end
