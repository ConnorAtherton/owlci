class ChangeActiveDefaultToFalse < ActiveRecord::Migration
  def change
    change_column :repos, :active, :boolean , default: false
  end
end
