class AddSortToCourseNames < ActiveRecord::Migration
  def self.up
    add_column :course_names, :sort, :integer
  end

  def self.down
    remove_column :course_names, :sort
  end
end
