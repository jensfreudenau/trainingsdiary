class AddTrainingsIdToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :trainings_id, :integer
  end

  def self.down
    remove_column :courses, :trainings_id
  end
end
