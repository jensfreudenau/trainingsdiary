require 'rexml/document'
require 'json'
require 'chronic_duration'
require 'pp'
load 'fileutils.rb'
class WorkoutsController < ApplicationController
  #include Devise::Controllers::Helpers
  # GET /workouts
  # GET /workouts.json
  def index
    @workouts = Workout.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workouts }
    end
  end

  # GET /workouts/1
  # GET /workouts/1.json
  def show
    @workout = Workout.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workout }
    end
  end

  # GET /workouts/new
  # GET /workouts/new.json
  def new

    @workout = Workout.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workout }
    end
  end

  # GET /workouts/1/edit
  def edit
    @workout = Workout.find(params[:id])
  end

  # POST /workouts
  # POST /workouts.json
  def create
    require 'pp'
    require 'yaml'
    require 'fileutils'
    @log = Logger.new('log/workout.log')
    Workout.mounting
    #@workout = Workout.new(params[:workout])
    puts 'params'
    pp params
    uploaded_io = params[:workout][:file_name].tempfile.path
    @log.debug(uploaded_io)
    save_file_data(uploaded_io)


    abort
    respond_to do |format|
      if @workout.save
        format.html { redirect_to @workout, notice: 'Workout was successfully created.' }
        format.json { render json: @workout, status: :created, location: @workout }
      else
        format.html { render action: "new" }
        format.json { render json: @workout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workouts/1
  # PUT /workouts/1.json
  def update
    @workout = Workout.find(params[:id])

    respond_to do |format|
      if @workout.update_attributes(params[:workout])
        format.html { redirect_to @workout, notice: 'Workout was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @workout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workouts/1
  # DELETE /workouts/1.json
  def destroy
    @workout = Workout.find(params[:id])
    @workout.destroy

    respond_to do |format|
      format.html { redirect_to workouts_url }
      format.json { head :ok }
    end
  end

  def save_file_data(file)
    pp file
    @file       = File.new(file, "r")
    @source_doc = Nokogiri::XML.parse(@file) { |cfg| cfg.noblanks }
    pp  @source_doc
  end
end
