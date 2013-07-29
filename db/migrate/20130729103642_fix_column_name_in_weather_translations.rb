class FixColumnNameInWeatherTranslations < ActiveRecord::Migration
  def change
    rename_column :weather_translations, :translation_id, :weather_id
  end

  def down
  end
end
