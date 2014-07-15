require 'rexml/document'
require 'json'
require 'active_support/inflector'
require 'chronic_duration'
require 'open-uri'
require 'fileutils.rb'

class TrainingsController < ApplicationController
  include Devise::Controllers::Helpers
  before_filter :authenticate_user!, :except => [:index, :show, :sort, :testxml]
  #load_and_authorize_resource
  #include Trainingsdata
  #include Bar
  # GET /trainings/newsimple
  # GET /trainings/newsimple.xml
  def newsimple

    @training = current_user.trainings.new
    @training.laps.build()

    @sportlevel = SportLevel.get_sportlevel_by_user(current_user.id)
    @sport      = Sport.get_sports_by_user(current_user.id)
    @coursename = CourseName.get_coursename_by_user(current_user.id)

    respond_to do |format|
      format.html # newsimple.html.erb
      format.xml { render :xml => @training }
    end
  end

  def index
    @log           = Logger.new('log/trainings.log')
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
                          .where(['trainings.user_id= ?', current_user])
                          .order(start_time: :desc)
                          .page params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @trainings }
    end

  end

  # GET /trainings/show
  # GET /trainings/show.xml
  def show
    @training = Training.select('
                        trainings.*,
                        w.temp as temperature,
                        w.weather as weather_description,
                        w.icon,
                        w.wind_speed,
                        w.humidity,
                        sport_levels.name as sportlevel,
                        trainings.start_time as start_time,
                        course_name_id as coursename,
                        sports.name as sportname,
                        course_names.name as coursename,
                        trainings.distance_total as distancetotal')
              .where('trainings.user_id = ? AND trainings.id = ?', current_user, params[:id])
              .joins(:course_name, :sport, :sport_level).joins('LEFT JOIN  weathers w
                        on trainings.id = w.training_id
                        and w.training_id  = (
                        select training_id from weathers where training_id = trainings.id
			                  order by w.id desc LIMIT 1) ')
              .order('w.id desc')
              .first

    @laps = Lap.where('training_id = ?', params[:id]).all
    if @training.icon?
      @icon_url = "#{@training.icon}.png"
      if @icon_url == '.png'
        @icon_url = "http://icons.wxug.com/i/c/g/#{@training.icon}.gif"
      end

    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @training }
    end
  end

  # GET /trainings/bigcalendar
  # GET /trainings/bigcalendar.xml
  def bigcalendar
    @calendar = Training.select(
        'trainings.id,
                                course_names.name as coursename,
                                sport_levels.name as sportlevel,
                                sport_levels.css as css,
                                sports.name as sportname,
                                time_total,
                                comment,
                                trainings.start_time as start_time,
                                distance_total')
    .order('start_time desc')
    .joins(:sport_level, :sport, :course_name)
    .limit(600)
    @calendardate = params[:month] ? Date.parse(params[:month]) : Date.today

    respond_to do |format|
      format.html # bigcalendar.html.haml
      format.xml { render :xml => @training }
    end
  end

  # GET /trainings/bigcalendar
  # GET /trainings/bigcalendar.xml
  def import_workouts
    respond_to do |format|
      format.html # import_workouts.html.haml
      format.xml { render :xml => @training }
    end
  end

  # GET /trainings/new
  # GET /trainings/new.xml
  def new

    @training = current_user.trainings.new

    @sportlevel = SportLevel.get_sportlevel_by_user(current_user.id)
    @sport      = Sport.get_sports_by_user(current_user.id)
    @coursename = CourseName.get_coursename_by_user(current_user.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @training }
    end
  end

  # GET /trainings/1/edit
  def edit
    
    @training = Training.where('trainings.user_id = ? AND trainings.id = ?', current_user, params[:id])
                        .select('trainings.*,
                                                    sport_levels.name as sportlevel,
                                                    trainings.start_time as start_time,
                                                    course_name_id as coursename,
                                                    sports.name as sportname,
                                                    trainings.distance_total as distancetotal')
                        .joins(:course_name, :sport, :sport_level)
                        .joins('LEFT JOIN "weathers" ON "weathers"."training_id" = "trainings"."id"')
                        .first

    unless @training.map_data.nil?
      if @training.map_data.length > 4
        load_weather_data

        @weather_desc = @weather
        weather = Weather.new
        if weather.wind_deg.nil?
          weather.training_id=@training.id
          weather.weather    = @weather
          weather.temp       = @temp
          weather.icon       = @icon
          weather.wind_speed = @speed
          weather.wind_deg   = @deg
          weather.humidity   = @humidity
          weather.save
        end

      end
    end
    @sportlevel = SportLevel.get_sportlevel_by_user(current_user.id)
    @sport      = Sport.get_sports_by_user(current_user.id)
    @coursename = CourseName.get_coursename_by_user(current_user.id)
  end


  # POST /trainings
  # POST /trainings.xml
  def create
    #@log = Logger.new('log/trainings.log')
    Training.mounting

    if params[:training][:start_time].empty?
      params[:training][:start_time] = Time.now.to_s(:db)
    end

    if !params[:training][:time_total].nil?
      params[:training][:time_total] = ChronicDuration::parse((params[:training][:time_total]))
    end

    @sportlevel = SportLevel.get_sportlevel_by_user(current_user.id)
    @sport      = Sport.get_sports_by_user(current_user.id)
    @coursename = CourseName.get_coursename_by_user(current_user.id)
    @training   = current_user.trainings.new(training_params)
    file_data = params[:training][:filename]
    respond_to do |format|
      #if @training.update_attributes(params[:training])
        if file_data
          self.save_file_data(file_data, html)
        end
        if @training.save
          format.html { redirect_to(trainings_url, :notice => 'Training was successfully updated.') }
          format.xml { head :ok }
        else
          format.html { render :action => 'new' }
          format.xml { render :xml => @training.errors, :status => :unprocessable_entity }
        end
      #end
    end
  end

  # PUT /trainings/1
  # PUT /trainings/1.xml#
  def update
    @log = Logger.new('log/trainings.log')
    Training.mounting
    file_data = params[:training][:filename]
    if params[:training][:start_time].nil?
      params[:training][:start_time] = Time.now.to_s(:db)
    end

    params[:training][:time_total] = ChronicDuration.parse(params[:training][:time_total].to_s)
    if !params[:training][:time_total].nil?
      params[:training][:time_total] = params[:training][:time_total].to_f
    end
    @training = Training.find(params[:id])
    @training.save
    respond_to do |format|
      if @training.update_attributes(params.require(:training).permit(:sport_id, :sport_level_id, :course_name_id, :time_total, :distance_total, :comment))
        if file_data
          self.save_file_data(file_data, 'html')
        end
        if @training.save


          format.html { redirect_to(trainings_url, :notice => 'Training was successfully updated.') }
          format.xml { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml { render :xml => @training.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /trainings/1
  # DELETE /trainings/1.xml
  def destroy
    @training = Training.find(params[:id])

    @training.destroy
    respond_to do |format|
      format.html { redirect_to(trainings_url, :notice => 'Training was successfully deleted.') }
      format.xml { head :ok }
      format.js
    end
  end

  def presave
    @log = Logger.new('log/trainings.log')
    xml = params[:training_xml]

    @coursename           = CourseName.get_last_coursename_by_user(current_user.id)
    @training             = Training.new(:user_id => current_user.id)
    @training.start_time  = Time.now

    @training.sport_id       = 1
    @training.sport_level_id = 1
    @training.course_name_id = @coursename.id
    @training.max_speed      = 0
    @training.save

    unless @training.id.nil?
      self.save_file_data(xml, true)
    end

    @training.save

    #render :js => "window.location = '/e/index'"
    render js: "window.location.pathname = #{edit_training_path(@training).to_json}"
    #render :nothing => true
  end

  protected
  def add_attachment
    # get file name
    file_name        = params[:qqfile]
    # get file content type
    att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
    # create temporal file
    file             = Tempfile.new(file_name)
    # put data into this file from raw post request
    file.print request.raw_post

    # create several required methods for this temporal file
    Tempfile.send(:define_method, "content_type") { return att_content_type }
    Tempfile.send(:define_method, "original_filename") { return file_name }

    # save file into attachment
    attach           = Attachment.new(:uploaded_data => file)
    attach.person_id = params[:person_id]
    attach.save!

    respond_to do |format|
      format.json { render(:layout => false, :json => { "success" => true, "data" => attach }.to_json) }
      format.html { render(:layout => false, :json => attach.to_json) }
    end
  rescue Exception => err
    respond_to do |format|
      format.json { render(:layout => false, :json => { "error" => err.to_s }.to_json) }
    end
  end

  def save_file_data(file_data, ajax)

    begin
      @td = Forerunner.new()
      if ajax == true
        file_or_xml = 'xml'
        @td.xml      = file_data
      elsif ajax == 'html'
        file_or_xml = 'file'
        @td.xml        = "http://s3-eu-west-1.amazonaws.com/trainingsdiary/uploads/training/filename/#{@training.user_id}/#{@training.id}/"+file_data
      end

      @td.start_import(file_or_xml)


      @distances          = Array.new
      @duration           = Array.new
      @heartrate_avg      = Array.new
      @calc_heartrate_avg = nil
      @training.save
      create_laps
      sports = Sport.get_sports_by_mnemonic(@td.sport)

      @training.sport_id       = sports.id
      @training.calories       = @td.calories
      @training.start_time     = @td.start_time
      @training.distance_total = @td.distance_total
      @training.time_total     = @td.time_total
      @training.map_data       = @td.map_data

      if @td.heartrate != false
        @training.heartrate       = @td.heartrate
        @training.heartrate_max   = @td.heartrate_max
        @training.heartrate_avg   = self.calculate_avg_heartrate
      end
      @training.height         = @td.height
      @training.time_in_move   = @td.diff_time_in_move
      @training.save
      weather             = Weather.new
      weather.training_id = @training.id
      weather.save
    end
  end

  def create_laps
    @td.laps.each do |index, value|

      @distances[index]     = value[:distance]
      @duration[index]      = value[:duration]

      unless value[:heartrate_avg].nil?
        @heartrate_avg[index] = value[:heartrate_avg]
        heartrate_avg         = value[:heartrate_avg]
        heartrate_max         = value[:heartrate_max]
        heartrate             = @td.lap_single_heartrate[index].to_json
      else
        heartrate_avg         = nil
        heartrate_max         = nil
        heartrate             = nil
      end

      @training.laps.create(
          :distance_total => value[:distance],
          :heartrate_avg  => heartrate_avg,
          :calories       => value[:calories],
          :heartrate_max  => heartrate_max,
          :duration       => value[:duration],
          :heartrate      => heartrate,
          :height         => @td.lap_single_height[index].to_json,
          :start_time     => value[:start_time],
          :map            => @td.lap_single_map[index].to_json,
          :maximum_speed  => value[:maximum_speed]
      )
      calculate_max_speed(value[:maximum_speed])

    end
  end

  def calculate_max_speed(max)
     if(@training.max_speed < max)
       @training.max_speed = max
     end
  end

  def calculate_avg_heartrate
    calc_heartrate_sum = 1
    res                = 1
    if @training.distance_total.to_f > 0
      begin
        @distances.each_with_index do |value, index|
          if (@heartrate_avg[index].nil?)
            @heartrate_avg[index] = nil
          end
          if (@distances[index] == 0.0)
            @distances[index] = 1.0
          end
          if @heartrate_avg[index] && !@heartrate_avg[index].nil?
            calc_heartrate_sum += @distances[index] * @heartrate_avg[index]
          end
        end
        res = calc_heartrate_sum/@training.distance_total
      rescue
        @log.debug('keine Streckenlaenge')
      end
      return res
    end

    if @training.time_total > 0
      begin
        @duration.each_with_index do |value, index|
          if (@heartrate_avg[index].nil?)
            @heartrate_avg[index] = nil
          end
          if (@duration[index] == 0.0)
            @duration[index] = 1.0
          end
          if @heartrate_avg[index] && !@heartrate_avg[index].nil?
            calc_heartrate_sum += @duration[index] * @heartrate_avg[index]
          end
        end
        res = calc_heartrate_sum/@training.time_total
      rescue
        @log.debug('keine Streckenzeit')
      end
      return res
    end
    @log.debug('calculate_avg_heartrate finished')
    return nil
  end

  def load_weather_data
    w_api          = Wunderground.new("4f8b96009743282f")
    w_api.language = 'DE'
    res            = @training.map_data.split('],[')
    unless res[2].nil?
      lat_lon = res[2].split(',')
      time    = DateTime.parse(@training['start_time'].to_s)
      h       = time.strftime("%H")
      unless lat_lon[0].nil?
        #if lat_lon[0].is_a? Numeric
          begin
            weather_data = w_api.history_for(time.strftime("%Y%m%d"), "#{lat_lon[0]},#{lat_lon[1]}")
            weather_data.each do |data, index|
              index.each do |v|
                v.each do |i|
                  if i.class.to_s == 'Array'
                    i.each do |f|
                      if f['date']['hour'].to_s == h.to_s   #durch das Wetter parsen bis wir die richtige stunde haben.
                        logger.debug f
                        @temp     = f['tempm']
                        @icon     = f['icon']
                        @weather  = f['conds']
                        @humidity = f['hum']
                        @speed    = f['wspdm']
                        @deg      = f['wdird']
                        return
                      end
                    end
                  end
                end
              end
            end
          end
        #end
      end
    end
  end

  private
  def training_params
    params.require(:training).permit(:training, :sport_level_id, :sport_id, :course_name_id, :time_total, :distance_total, :comment, :start_time )
  end
end
