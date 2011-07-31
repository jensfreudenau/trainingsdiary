class AddHeartrateToTraining < ActiveRecord::Migration
  def self.up
    add_column :trainings, :heartrate, :text
  end

  def self.down
    remove_column :trainings, :heartrate
  end
end
