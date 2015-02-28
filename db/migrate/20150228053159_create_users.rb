class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :name
      t.string :avatar
      t.string :access_token

      t.timestamps
    end
  end
end
