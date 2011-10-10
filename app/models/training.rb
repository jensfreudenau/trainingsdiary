class Training < ActiveRecord::Base
    belongs_to :user
    belongs_to :sport_level
    belongs_to :sport
    belongs_to :course_name
    has_many :laps, :dependent => :destroy
    
    def self.mounting
      mount_uploader :filename, FileUploader
    end
    
    default_scope order('trainings.start_time DESC')
    validates :start_time, :presence => true
    validates :sport_id, :presence => true

    def self.get_sportlevel(user_id)
      return SportLevel.find(
                                        :all,
                                        :select => 'id, name',
                                        :conditions => {:user_id => user_id}
                                        )
    end
    
    def self.get_sports (user_id)
      return Sport.find(
                            :all,
                            :select => 'id, name',
                            :conditions => {:user_id => user_id}
                          )
    end
    
    def self.get_coursename (user_id)
      return CourseName.find(
                                        :all,
                                        :select => 'id, name',
                                        :conditions => {:user_id => user_id}
                                      )
    end
end
