class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.integer :user_id
      t.integer :sport_id
      t.text :waypoints
      t.string :distance
      t.string :duration
      t.string :min_per_km
      t.timestamps
    end
  end
end
