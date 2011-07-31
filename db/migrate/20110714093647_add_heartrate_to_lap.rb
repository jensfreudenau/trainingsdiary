class AddHeartrateToLap < ActiveRecord::Migration
  def self.up
    add_column :laps, :heartrate, :text
  end

  def self.down
    remove_column :laps, :heartrate
  end
end
