require "date"

class ApplicationController < ActionController::Base
    helper :all
    
    before_filter :authenticate_user!, :except => [:index, :show]
    before_filter :set_locale, :set_time_zone, :list_last_trainings, :calendar, :statistic
    protect_from_forgery
    
    rescue_from CanCan::AccessDenied do |exception|
        Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
        flash[:error] = exception.message
        redirect_to root_url
    end

    def set_time_zone
        Time.zone = current_user.time_zone unless current_user.blank?
    end
    
    def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
    end
    
    def list_last_trainings
      @last_trainings = Training.all(
                                        #:conditions => ['trainings.user_id = ?', current_user ],
                                        :select => '
                                            trainings.id,
                                            trainings.sport_level_id,
                                            course_names.name as coursename,
                                            sport_levels.name as sportlevel,
                                            sport_levels.css as css,
                                            sports.name as sportname,
                                            trainings.time_total,
                                            trainings.start_time,
                                            distance_total as distance',
                                        :order => 'trainings.start_time DESC',
                                        :joins => [:sport_level, :sport, :course_name],
                                        :limit => 3)
        #@last_trainings = Training.find(:all,
        #                                        :conditions => ['trainings.user_id = ?', current_user ],
        #                                        :select => '
        #                                            trainings.id,
        #                                            trainings.sport_level_id,
        #                                            course_names.name as coursename,
        #                                            sport_levels.name as sportlevel,
        #                                            sport_levels.css as css,
        #                                            sports.name as sportname,
        #                                            trainings.time_total,
        #                                            trainings.start_time,
        #                                            distance_total as distance',
        #                                        :order => 'trainings.start_time DESC',
        #                                        :joins => [:sport_level, :sport, :course_name],
        #                                        :limit => 3)
    end
    
    def statistic      
        #@log = Logger.new('log/applic.log')
        @sports = Sport.all(
            :select => 'id, name',
            :order => 'id DESC'
        )
        if params[:week] 
          @from_date = DateTime.parse(params[:week])
        else
          @from_date = DateTime.now
        end
        @report = Hash.new
        @sports.each do |sport|

        @report[sport.name.to_s] = Training.sum('distance_total', :conditions => {
                                                              :sport_id => sport.id,  
                                                              :start_time => @from_date.beginning_of_week..@from_date.end_of_week })
        
        end       
    end
      
    def calendar
        @calendartrainings = Training.all(
            :select => 'trainings.id,
                            course_names.name as coursename,
                            sport_levels.name as sportlevel,
                            sport_levels.css as css,
                            sports.name as sportname,
                            time_total,
                            comment,
                            trainings.start_time as start_time,
                            distance_total',
            :order => 'start_time desc',
            :joins => [:sport_level, :sport, :course_name],
            :limit => 600)
        @date = params[:month] ? Date.parse(params[:month]) : Date.today
    end
end