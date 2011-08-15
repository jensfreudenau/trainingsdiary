class StatisticsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  def index
    @log = Logger.new('log/home.log')
 
    @current_week = DateTime.now.beginning_of_week.beginning_of_day
     
    @week = DateTime.now.months_ago(8).beginning_of_week.beginning_of_day

    @sports = Sport.unscoped.find(
      :all,
      :select => 'id, name',
      :order => 'sort_order DESC',
      :conditions => ['sports.user_id = ?', current_user.id]
    )
    @log.debug(@sports)
    
    @statistic = Hash.new
    @sports.each do |sport|
      while @week <= @current_week

        @statistic[sport.name.to_s] ||= {}
        training = Training.sum( 'distance_total',
            :conditions => {
              :sport_id => sport.id,
              :user_id => current_user,
              :start_time => @week..@week.end_of_week })
        
        
        @statistic[sport.name.to_s][@week.strftime('%Y, %m, %d').to_s] = training/1000.to_f

        @week += 7.days
        @week = @week.beginning_of_week
      end
      @week = DateTime.now.months_ago(8).beginning_of_week.beginning_of_day
    end
    @statistic['Radfahren'] = @statistic['Radfahren'].sort
    @statistic['Laufen'] = @statistic['Laufen'].sort
    @statistic = @statistic.to_json

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @statistic }
    end
  end

end