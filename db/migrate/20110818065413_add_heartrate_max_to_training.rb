class AddHeartrateMaxToTraining < ActiveRecord::Migration
  def self.up
    add_column :trainings, :heartrate_max, :integer
  end

  def self.down
    remove_column :trainings, :heartrate_max
  end
end
