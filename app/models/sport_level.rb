class SportLevel < ActiveRecord::Base
  has_many :trainings
  belongs_to :user  
  default_scope :order => 'sort'   
  def self.get_sportlevel_by_user(user_id)
      return SportLevel.find(
                                        :all,
                                        :select => 'id, name',
                                        :conditions => {:user_id => user_id}
                                        )
    end
end
