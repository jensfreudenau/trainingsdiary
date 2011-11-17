class HomeController < ApplicationController
  #before_filter :authenticate_user!, :except => [:index, :show, :bigmap]
   
  def index 
    #@log = Logger.new('log/home.log')   
    items_per_page = 7

    trainings = Training.find(:all,                                    
                                    :select => '
                                        trainings.id,
                                        trainings.map_data,
                                        trainings.sport_level_id,
                                        trainings.comment,
                                        trainings.heartrate_avg,
                                        trainings.heartrate_max, 
                                        course_names.name as coursename,
                                        sport_levels.name as sportlevel,
                                        sport_levels.css as css,
                                        sports.name as sportname,
                                        time_total,
                                        trainings.start_time as start_time,
                                        distance_total',
                                    :order => 'start_time',
                                    :joins => [:sport_level, :sport, :course_name])
  @trainings = trainings.paginate:page => params[:page], :per_page => items_per_page
  end
  
  def bigmap
    @map = Training.find(:all, 
                          :select => 'trainings.map_data',
                          :conditions => ['trainings.id = ?', params[:id]])
    render :partial => 'bigmap.html.haml'
  end
  
  
  def show
    @home = Training.find(:all, 
                          :select => '    
                                  trainings.id,
                                  trainings.comment,
                                  trainings.map_data,
                                  trainings.heartrate,
                                  trainings.time_total,
                                  trainings.height,
                                  trainings.heartrate_avg,
                                  trainings.heartrate_max,                        
                                  trainings.start_time as start_time,
                                  trainings.distance_total as distance_total,
                                  course_names.name as coursename,
                                  sport_levels.name as sportlevel,
                                  sports.name as sportname
                          ',
                          :joins => [ :course_name, :sport, :sport_level] ,
                          :conditions => ['trainings.id = ?', params[:id]])
    @laps = Lap.find(
        :all,
        :conditions => ['training_id = ?', params[:id]]
    )                          
    respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @training }
    end
  end  
end
