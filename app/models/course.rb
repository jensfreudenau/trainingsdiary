class Course < ActiveRecord::Base
  belongs_to :sport
  belongs_to :user
  
  def self.mounting
    mount_uploader :file, FileUploader
  end
end