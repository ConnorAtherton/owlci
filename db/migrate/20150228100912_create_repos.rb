class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :full_name
      t.boolean :private
      t.string :html_url
      t.boolean :active
      t.belongs_to :user
      t.integer :hook_id

      t.timestamps
    end
  end
end
