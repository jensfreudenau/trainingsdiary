class StatisticsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def index
    @log = Logger.new('log/home.log') 
    date = Date.today.strftime('%W')
    @current_week = Date.today.strftime('%W')
    year = Date.today.strftime('%Y')
    
     


    month = DateTime.now.months_ago(6)
    
    @start_week = month.beginning_of_week
    
    
    @sports = Sport.find(
        :all,
        :select => 'id, name',
        :conditions => ['sports.user_id = ?', 1]
    )
    #if params[:week] 
    #  @from_date = DateTime.parse(params[:week])
    #else
    #  
    #end
    @from_date = DateTime.now
    @week_nr = @start_week.strftime('%W')
    week = @week_nr.to_i
    @statistic = Hash.new
    @sports.each do |sport|
      while week <= @current_week.to_i
        week +=1
        @statistic[sport.name.to_s] ||= {}
        training = Training.sum( 'distance_total', 
                                                            :conditions => { 
                                                              :sport_id => sport.id,  
                                                              :user_id => 1, 
                                                              :start_time => @start_week..@start_week.end_of_week })
        @statistic[sport.name.to_s][week.to_s] = training/1000.to_f
        
        @start_week = Date.commercial(year.to_i, week, 1)

        @start_week = @start_week.beginning_of_week
        
      end
      @statistic[sport.name.to_s]
      week = @week_nr.to_i
      
      @week_nr = @start_week.strftime('%W').to_i + 1
      
    end
    @statistic = @statistic.to_json
    respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @statistic }
    end
  end
  
end