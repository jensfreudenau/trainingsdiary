class PagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :bigmap, :listen]

  def index  
    @trainings = Training.select('
                        trainings.*,                        
                        sport_levels.name as sportlevel,
                        sport_levels.css as css,
                        trainings.start_time as start_time,
                        course_name_id as coursename,
                        sports.name as sportname,                          
                        course_names.name as coursename,
                        trainings.distance_total as distancetotal')
              .joins(:course_name, :sport, :sport_level)
              .order(start_time: :desc)
              .page params[:page]  
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
    @trainings = Training.select('trainings.id,
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
                                                distance_total')
              .joins(:course_name, :sport, :sport_level)
              .order(sort)
              .page(params[:page])
              .per(2000)
    # @trainings = Training.paginate(:select => 'trainings.id,
    #                                             trainings.sport_level_id,
    #                                             trainings.comment,
    #                                             trainings.heartrate_avg,
    #                                             trainings.heartrate_max,
    #                                             course_names.name as coursename,
    #                                             sport_levels.name as sportlevel,
    #                                             sport_levels.css as css,
    #                                             sports.name as sportname,
    #                                             time_total,
    #                                             trainings.start_time as start_time,
    #                                             distance_total',
    #                                :order => sort,
    #                                :joins => [:sport_level, :sport, :course_name],
    #                                :page => params[:page], :per_page => 2000)
  end


  def show
    @home = Training.select('
                        trainings.*,
                        weathers.temp as temperature,
                        weathers.icon,
                        weathers.wind_speed,
                        weathers.humidity,
                        sport_levels.name as sportlevel,
                        trainings.start_time as start_time,
                        course_name_id as coursename,
                        sports.name as sportname,
                        course_names.name as coursename,
                        trainings.distance_total as distancetotal')
              .where('trainings.id = ?', params[:id])
              .joins(:course_name, :sport, :sport_level).joins('LEFT JOIN "weathers" ON "weathers"."training_id" = "trainings"."id"')
              .first

    @laps = Lap.where('training_id = ?', params[:id]).all
    if @home.icon?
      @icon_url = "#{@home.icon}.png"
      if @icon_url == ".png"
        @icon_url = "http://icons.wxug.com/i/c/g/#{@home.icon}.gif"
      end

    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @home }
    end
  end

end
