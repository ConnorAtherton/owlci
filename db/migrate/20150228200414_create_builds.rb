class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.belongs_to :repo, index: true
      t.string :action
      t.integer :number
      t.string :head_sha
      t.string :head_repo_full_name
      t.string :head_ssh_url
      t.string :base_sha
      t.string :base_repo_full_name
      t.string :base_ssh_url
      t.string :title
      t.string :html_url
      t.integer :state

      t.timestamps
    end
  end
end
