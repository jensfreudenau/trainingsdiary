class AddHeightToTraining < ActiveRecord::Migration
  def self.up
    add_column :trainings, :height, :text
  end

  def self.down
    remove_column :trainings, :height
  end
end
