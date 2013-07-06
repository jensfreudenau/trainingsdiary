class Workout < ActiveRecord::Base
  belongs_to :user
  has_many :workout_stepses

  def self.mounting
    mount_uploader :file_name, FileUploader
  end
end
