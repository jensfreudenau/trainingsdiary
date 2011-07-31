class CreateSportLevels < ActiveRecord::Migration
  def self.up
    create_table :sport_levels do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sport_levels
  end
end
