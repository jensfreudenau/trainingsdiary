class PagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :bigmap, :listen]

  def index
    #@log = Logger.new('log/home.log')   
    items_per_page = 7
    @trainings = Training.paginate(:select => 'trainings.id,
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
                                   :order => 'id DESC',
                                   :joins => [:sport_level, :sport, :course_name],
                                   :page => params[:page], :per_page => items_per_page)
  end

  def bigmap

    @map = Training.select('trainings.map_data')
                  .where( 'trainings.id = ?', params[:id])


    render :partial => 'bigmap.html.haml'
  end

  def listen
    sort = case params['sort']
             when 'name' then
               'coursename, start_time DESC'
             when 'sportlevel' then
               'sport_levels.name, start_time DESC'
             when 'sports.name' then
               'sports.name, start_time DESC'
             when 'start_time' then
               'start_time DESC'
             when 'time_total' then
               'time_total ASC, start_time DESC'
             when 'distance' then
               'trainings.distance_total, start_time DESC'
             when 'heartrate_avg' then
               'heartrate_avg, start_time DESC'
             when 'comment' then
               'comment DESC, start_time DESC'
             else
               'trainings.start_time DESC'
           end
    @trainings = Training.paginate(:select => 'trainings.id,
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
                                   :order => sort,
                                   :joins => [:sport_level, :sport, :course_name],
                                   :page => params[:page], :per_page => 200)
  end


  def show

    @home = Training.all(
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
        :joins => [:course_name, :sport, :sport_level],
        :conditions => ['trainings.id = ?', params[:id]])

    @laps = Lap.all(
        :conditions => ['training_id = ?', params[:id]]
    )

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @home }
    end
  end

end
