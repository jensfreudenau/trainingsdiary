class CourseName < ActiveRecord::Base
	has_many :trainings
	belongs_to :user
	default_scope :order => 'sort'
  validates :name, :presence => true
  
  def self.get_coursename_by_user (user_id)
      return CourseName.find(
                                        :all,
                                        :select => 'id, name',
                                        :conditions => {:user_id => user_id}
                                      )
    end
end
