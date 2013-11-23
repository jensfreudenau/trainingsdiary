class Sport < ActiveRecord::Base
  has_many :trainings
  has_many :downloads
  belongs_to :user
  default_scope :order => 'sort_order' 
  scope :unorder,  order('sort_order DESC')

  def self.get_sports_by_mnemonic(mnemonic)
    return Sport.where('mnemonic = ?', mnemonic).first
  end

  def self.get_sports_by_user (user_id)
      return Sport.select('id, name').where('sports.user_id = ?',user_id)
  end

  def self.get_sport_type_by_id(id)
    sport = Sport.find(id)
    if sport.mnemonic == 'Biking'
      return 'BICYCLING'
    end
    if sport.mnemonic == 'Running'
      return 'WALKING'
    end
  end
end
