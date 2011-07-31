class Ability
    include CanCan::Ability
  
    def initialize(user)
        #user ||= User.new # guest user
        if user.role.name == "admin"
            can :manage, :all 
        else
            can :read, :all
            can :create, Training 
            can :update, Training 
            #can :update, Training do |training|
            #    training.try(:user) == user
            #end
            can :destroy, Training do |training|
                training.try(:user) == user
            end
            can :create, Sport 
            can :update, Sport do |sport|
                sport.try(:user) == user
            end
            can :destroy, Sport do |sport|
                sport.try(:user) == user
            end
            can :create, SportLevel 
            can :update, SportLevel
            can :destroy, SportLevel do |sportLevel|
                sportLevel.try(:user) == user
            end
            can :create, CourseName 
            can :update, CourseName do |courseName|
                courseName.try(:user) == user
            end
            can :destroy, CourseName do |courseName|
                courseName.try(:sportLevel) == user
            end
        end
    end
end
