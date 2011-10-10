class Course < ActiveRecord::Base
  belongs_to :sport
  belongs_to :user
  validates :name, :presence => true
  def self.mounting
    mount_uploader :file, FileUploader
  end
end