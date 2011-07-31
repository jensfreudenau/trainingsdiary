class CreateTrainings < ActiveRecord::Migration
  def self.up
    create_table :trainings do |t|
      t.integer :user_id
      t.integer :sport_id
      t.integer :sport_level_id
      t.integer :course_name_id
      t.float :time_total
      t.float :distance_total
      t.datetime :published_at
      t.text :map_data
      t.string :filename
      t.timestamps
    end
  end

  def self.down
    drop_table :trainings
  end
end
