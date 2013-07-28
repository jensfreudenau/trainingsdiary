class AddTranslationIdToWeatherTranslations < ActiveRecord::Migration
  def change
    add_column :weather_translations, :translation_id, :integer
  end
end
