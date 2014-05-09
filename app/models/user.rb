class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable
    belongs_to :role
    has_many :trainings
    has_many :sports
    has_many :course_names
    has_many :sport_levels
    has_many :workouts
    has_many :tracks
    #include Mongoid::Document
    # Setup accessible (or protected) attributes for your model
    #attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :role_id, :time_zone
	
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable, :lockable and :timeoutable
    devise :database_authenticatable,  :recoverable, :rememberable, :trackable, :validatable #, :token_authenticatable
    def self.current
        Thread.current[:user]
    end
    def self.current=(user)
      Thread.current[:user] = user
    end
    
end
