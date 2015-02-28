class AddSshUrlToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :ssh_url, :string
  end
end
