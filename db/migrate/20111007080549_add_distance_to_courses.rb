class AddDistanceToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :distance, :string
  end

  def self.down
    remove_column :courses, :distance
  end
end
