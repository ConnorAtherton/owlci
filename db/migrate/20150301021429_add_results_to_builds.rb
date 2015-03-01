class AddResultsToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :results, :text
  end
end
