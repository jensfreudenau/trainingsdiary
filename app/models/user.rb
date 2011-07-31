class User < ActiveRecord::Base
    belongs_to :role
    has_many :trainings
    has_many :sports
    has_many :course_names
    has_many :sport_levels
    #include Mongoid::Document
    # Setup accessible (or protected) attributes for your model
    attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :role_id, :time_zone
	
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable, :lockable and :timeoutable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable
    def self.current
        Thread.current[:user]
    end
    def self.current=(user)
      Thread.current[:user] = user
    end
    
end
