class AddHeartrateAvgToTraining < ActiveRecord::Migration
  def self.up
    add_column :trainings, :heartrate_avg, :integer
  end

  def self.down
    remove_column :trainings, :heartrate_avg
  end
end
