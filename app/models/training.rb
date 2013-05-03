class Training < ActiveRecord::Base

    belongs_to :user
    belongs_to :sport_level
    belongs_to :sport
    belongs_to :course_name
    has_many :laps, :dependent => :destroy
    
    def self.mounting
      mount_uploader :filename, FileUploader
    end
    
    #default_scope order('trainings.start_time DESC')
    validates :start_time, :presence => true
    validates :sport_id, :presence => true
    
end
