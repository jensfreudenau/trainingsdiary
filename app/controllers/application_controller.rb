require "date"
require 'pp'

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
    @last_trainings = Training.select('
                        trainings.*,
                        distance_total as distance,
                        sport_levels.name as sportlevel,
                        sport_levels.css as css,
                        trainings.start_time,
                        course_names.name as coursename,
                        sports.name as sportname')
    .joins(:course_name, :sport, :sport_level)
    .order(start_time: :desc)
    .limit(5)
  end

  def statistic
    #@log = Logger.new('log/applic.log')
    @sports = Sport.select('id, name').order(id: :desc)
    if params[:week]
      @from_date = DateTime.parse(params[:week])
    else
      @from_date = DateTime.now
    end
    @report = Hash.new
    @sports.each do |sport|

      @report[sport.name.to_s] = Training.weekly(sport.id, @from_date)

          #sum(:distance_total, :conditions => {
          #:sport_id   => sport.id,
          #:start_time => @from_date.beginning_of_week..@from_date.end_of_week })

    end
  end

  def calendar
    @calendartrainings = Training.select('trainings.id,
                            course_names.name as coursename,
                            sport_levels.name as sportlevel,
                            sport_levels.css as css,
                            sports.name as sportname,
                            time_total,
                            comment,
                            trainings.start_time as start_time,
                            distance_total')
        .joins(:course_name, :sport, :sport_level)
        .order(start_time: :desc)
        .limit(600)

    @date              = params[:month] ? Date.parse(params[:month]) : Date.today
  end
end