require 'rexml/document'
require 'json'
require 'active_support/inflector'
require 'chronic_duration'
require 'pp'
require 'open-uri'

load 'fileutils.rb'


class TrainingsController < ApplicationController
  include Devise::Controllers::Helpers
  before_filter :authenticate_user!, :except => [:index, :show, :sort]
  #load_and_authorize_resource
  include Trainingsdata

  def index
    @log = Logger.new('log/trainings.log')

    #@files = Dir.glob("public/tracks/uploader/temp/*.TCX", File::FNM_CASEFOLD)
    #
    #for file in @files

    # self.batch(file)
    # end
    #
    items_per_page = 7
    sort = case params['sort']
             when "name" then
               "name"
             when "sportlevel" then
               "sport_levels.name"
             when "sports.name" then
               "sports.name"
             when "start_time" then
               "start_time ASC"
             when "time_total" then
               "time_total ASC"
             when "distance" then
               "distance_total"
             else
               "trainings.start_time DESC"
           end

    dir = case params['dir']
            when "asc" then
              "ASC"
            when "desc" then
              "DESC"
            else
              "ASC"
          end

    @trainings = Training.paginate(
        :conditions => ['trainings.user_id = ?', current_user],
        :select => 'trainings.id,
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
        :order => 'start_time DESC',
        :joins => [:sport_level, :sport, :course_name],
        :page => params[:page], :per_page => items_per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @trainings }
    end

  end

  # GET /trainings/1
  # GET /trainings/1.xml
  def show

    @training = Training.select('
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
                        .where('trainings.user_id = ? AND trainings.id = ?', current_user, params[:id])
                        .joins(:course_name, :sport, :sport_level).joins('LEFT JOIN "weathers" ON "weathers"."training_id" = "trainings"."id"')
                        .first

    @laps = Lap.where('training_id = ?', params[:id]).all
    if @training.icon?
      @icon_url = "http://icons.wxug.com/i/c/g/#{@training.icon}.gif"
      @icon_url = "#{@training.icon}.png"

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
    @log = Logger.new('log/trainings.log')
    w_api = Wunderground.new("4f8b96009743282f")
    w_api.language = 'DE'


    @training = Training.where('trainings.user_id = ? AND trainings.id = ?', current_user, params[:id])
                        .select('trainings.*,
                                sport_levels.name as sportlevel,
                                trainings.start_time as start_time,
                                course_name_id as coursename,
                                sports.name as sportname,
                                trainings.distance_total as distancetotal')
                        .joins(:course_name, :sport, :sport_level, :weather)
                        .first

    res       =  @training.map_data.split('],[')
    lat_lon   = res[2].split(',')
    time      = DateTime.parse(@training['start_time'].to_s)
    h         = time.strftime("%H")
    weather_data = w_api.history_for(time.strftime("%Y%m%d"), "#{lat_lon[0]},#{lat_lon[1]}")
    weather_data.each do |data, index|
      index.each do |v|
        v.each do |i|
          if i.class.to_s == 'Array'
            i.each do |f|
              @log.debug(f['date']['hour'].to_yaml)
              if f['date']['hour'].to_s == h.to_s

                @temp       = f['tempm']
                @icon       = f['icon']
                @weather    = f['conds']
                @humidity   = f['hum']
                @speed      = f['wspdm']
                @deg        = f['wdird']
              end
            end
          end
        end
      end
    end
    @weather_desc = @weather
    @sportlevel   = SportLevel.get_sportlevel_by_user(current_user.id)
    @sport        = Sport.get_sports_by_user(current_user.id)
    @coursename   = CourseName.get_coursename_by_user(current_user.id)
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
    @training   = current_user.trainings.new(params[:training])


    file_data = params[:training][:filename]
    respond_to do |format|
      if @training.update_attributes(params[:training])
        if file_data
          self.save_file_data(file_data, html)
        end
        if @training.save

          format.html { redirect_to(trainings_url, :notice => 'Training was successfully updated.') }
          format.xml { head :ok }
        else
          format.html { render :action => "new" }
          format.xml { render :xml => @training.errors, :status => :unprocessable_entity }
        end
      end
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
    @training       = Training.find(params[:id])
    @training.save
    respond_to do |format|

      if @training.update_attributes(params[:training])
        if file_data
          self.save_file_data(file_data, 'html')
        end
        if @training.save


          format.html { redirect_to(trainings_url, :notice => 'Training was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @training.errors, :status => :unprocessable_entity }
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
    #skip_before_filter :verify_authenticity_token
    xml = params[:training_xml]

    @coursename           = CourseName.get_last_coursename_by_user(current_user.id)

    @training             = Training.new(:user_id => 1)
    @training.start_time  = Time.now

    @training.sport_id       = 1
    @training.sport_level_id = 1
    @training.course_name_id = @coursename.id
    @training.save

    unless @training.id.nil?
      @log.debug('jetzt das xml auswerten')
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
    file_name = params[:qqfile]
    # get file content type
    att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
    # create temporal file
    file = Tempfile.new(file_name)
    # put data into this file from raw post request
    file.print request.raw_post

    # create several required methods for this temporal file
    Tempfile.send(:define_method, "content_type") { return att_content_type }
    Tempfile.send(:define_method, "original_filename") { return file_name }

    # save file into attachment
    attach = Attachment.new(:uploaded_data => file)
    attach.person_id = params[:person_id]
    attach.save!

    respond_to do |format|
      format.json { render(:layout => false, :json => {"success" => true, "data" => attach}.to_json) }
      format.html { render(:layout => false, :json => attach.to_json) }
    end
  rescue Exception => err
    respond_to do |format|
      format.json { render(:layout => false, :json => {"error" => err.to_s}.to_json) }
    end
  end

  def save_file_data(file_data, ajax)
    begin

      if ajax == true
        file_or_xml = 'xml'
        td = Trainingsdata::Forerunner.new()
        td.xml = file_data
      elsif ajax == 'html'
        file_or_xml = 'file'
        path = "http://s3-eu-west-1.amazonaws.com/trainingsdiary/uploads/training/filename/#{@training.user_id}/#{@training.id}/"+file_data
        td = Trainingsdata::Forerunner.new()
        td.xml = path
      end

      td.start_import(file_or_xml)
      @log.debug('import finished')
      @distances          = Array.new
      @duration           = Array.new
      @heartrate_avg      = Array.new
      @calc_heartrate_avg = 0

      td.laps.each do |index, value|

        @distances[index.to_i]      = value[:distance]
        @duration[index.to_i]       = value[:duration]
        @heartrate_avg[index.to_i]  = value[:heartrate_avg]

        @training.laps.create(
            :distance_total     => value[:distance],
            :heartrate_avg      => value[:heartrate_avg],
            :calories           => value[:calories],
            :heartrate_max      => value[:heartrate_max],
            :duration           => value[:duration],
            :heartrate          => td.lap_single_heartrate[index].to_json,
            :height             => td.lap_single_height[index].to_json,
            :start_time         => value[:start_time],
            :map                => td.lap_single_map[index].to_json,
            :maximum_speed      => value[:maximum_speed]
        )
      end
      sports = Sport.get_sports_by_mnemonic(td.sport)

      @training.sport_id        = sports.id
      @training.calories        = td.calories
      @training.start_time      = td.start_time
      @training.distance_total  = td.distance_total
      @training.time_total      = td.time_total
      @training.map_data        = td.map_data
      @training.heartrate       = td.heartrate
      @training.height          = td.height
      @training.heartrate_avg   = self.calculate_avg_heartrate
      @training.heartrate_max   = td.heartrate_max

      @training.save
      weather = Weather.new
      weather.training_id=@training.id
      weather.save
    end
  end

  def calculate_avg_heartrate
    @log.debug(@training)
    calc_heartrate_sum  = 1
    res                 = 1
    if @training.distance_total.to_f > 0
      begin
        @distances.each_with_index do |value, index|
          if (@heartrate_avg[index.to_i].nil?)
            @heartrate_avg[index.to_i] = 1
          end
          if (@distances[index.to_i] == 0.0)
            @distances[index.to_i] = 1.0
          end
          if @heartrate_avg[index.to_i] && !@heartrate_avg[index.to_i].nil?
            calc_heartrate_sum += @distances[index.to_i] * @heartrate_avg[index.to_i]
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
          if (@heartrate_avg[index.to_i].nil?)
            @heartrate_avg[index.to_i] = 1
          end
          if (@duration[index.to_i] == 0.0)
            @duration[index.to_i] = 1.0
          end
          if @heartrate_avg[index.to_i] && !@heartrate_avg[index.to_i].nil?
            calc_heartrate_sum += @duration[index.to_i] * @heartrate_avg[index.to_i]
          end
        end
        res = calc_heartrate_sum/@training.time_total
      rescue
        @log.debug('keine Streckenzeit')
      end
      return res
    end
    @log.debug('calculate_avg_heartrate finished')
    return 1
  end

  def batch (file)
    f = File.open(file, "r")
    @training = current_user.trainings.new()
    @training.user_id = @training.user_id
    @training.sport_id = 5
    @training.sport_level_id = 1
    @training.course_name_id = 4
    @training.filename = File.basename(file).to_s
    @training_orl = Training.find(:first,
                                  :conditions => {:user_id => @training.user_id, :filename => @training.filename},
                                  :select => 'id')

    if @training_orl.nil?
      @training.save

      FileUtils.mv file, "public/tracks/uploader/ok/"+File.basename(file).to_s
      begin

        td = Trainingsdata::Forerunner.new()

        td.laps.each_with_index do |value, index|

          @training.laps.create(
              :distance_total => value[:distance],
              :heartrate_avg  => value[:heartrate_avg],
              :calories       => value[:calories],
              :heartrate_max  => value[:heartrate_max],
              :duration       => value[:duration],
              :heartrate      => value[:heartrate].to_json,
              :height         => value[:height].to_json,
              :map            => value[:map].to_json,
              :start_time     => value[:time]
          )
        end

        @training.distance_total = td.distance_total
        @training.time_total = td.time_total
        @training.calories    = td.calories
        @training.map_data = td.map_data
        @training.heartrate = td.heartrate
        @training.heartrate_avg = td.heartrate_avg
        @training.heartrate_max = td.heartrate_max
        @training.height = td.height
        @training.save
      end
    end
  end

end
