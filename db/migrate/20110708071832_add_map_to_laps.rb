class AddMapToLaps < ActiveRecord::Migration
  def self.up
    add_column :laps, :map, :text
  end

  def self.down
    remove_column :laps, :map
  end
end
