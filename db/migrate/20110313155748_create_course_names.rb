class CreateCourseNames < ActiveRecord::Migration
  def self.up
    create_table :course_names do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :course_names
  end
end
