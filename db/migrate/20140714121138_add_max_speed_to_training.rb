class AddMaxSpeedToTraining < ActiveRecord::Migration
  def change
    add_column :trainings, :max_speed, :string
  end
end
