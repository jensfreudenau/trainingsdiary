class AddHeightToLap < ActiveRecord::Migration
  def self.up
    add_column :laps, :height, :text
  end

  def self.down
    remove_column :laps, :height
  end
end
