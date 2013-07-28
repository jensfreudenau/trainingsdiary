class CreateWeatherTranslations < ActiveRecord::Migration
  def change
    create_table :weather_translations do |t|
      t.integer :id
      t.string :de

      t.timestamps
    end
  end
end
