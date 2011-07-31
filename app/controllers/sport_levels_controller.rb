class SportLevelsController < ApplicationController
  # GET /sport_levels
  # GET /sport_levels.xml
 #load_and_authorize_resource
  before_filter :authenticate_user!, :except => [:sort]
   
  def index
     @sport_levels = SportLevel.find(
            :all,
            :conditions => {:user_id => current_user.id }
            )
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sport_levels }
    end
  end
  
  # GET /sport_levels/1
  # GET /sport_levels/1.xml
  def show
    @sport_level = SportLevel.find(
        :first,
        :conditions => {:user_id => current_user.id , :id => params[:id]}
        )
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sport_level }
    end
  end
  
  # GET /sport_levels/new
  # GET /sport_levels/new.xml
  def new
    @sport_level = SportLevel.new
    
    respond_to do | format|
      format.html # new.html.erb
      format.xml  { render :xml => @sport_level }
    end
  end
  
  # GET /sport_levels/1/edit
  def edit
    @sport_level = SportLevel.find(
    									:first,
    									:conditions => {:user_id => current_user.id , :id => params[:id]})
  end
  
  # POST /sport_levels
  # POST /sport_levels.xml
  def create
    params[:sport_level][:user_id] = current_user.id
    @sport_level = SportLevel.new(params[:sport_level])
    
    respond_to do |format|
      if @sport_level.save
        format.html { redirect_to(sport_levels_url, :notice => 'Sport level was successfully created.') }
        format.xml  { render :xml => @sport_level, :status => :created, :location => @sport_level }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sport_level.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /sport_levels/1
  # PUT /sport_levels/1.xml
  def update
    @sport_level = SportLevel.find(params[:id])
    
    respond_to do |format|
      if @sport_level.update_attributes(params[:sport_level])
        format.html { redirect_to(sport_levels_url, :notice => 'Sport level was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sport_level.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /sport_levels/1
  # DELETE /sport_levels/1.xml
  def destroy
    @sport_level = SportLevel.find(params[:id])
    @sport_level.destroy
    
    respond_to do |format|
      format.html { redirect_to(sport_levels_url) }
      format.xml  { head :ok }
    end
  end
  
  def sort
    @sport_levels = SportLevel.all
    @sport_levels.each do |sport_level|
      sport_level.sort = params[:list].index(sport_level.id.to_s)
      sport_level.save
    end 
    render :nothing => true 
  end
end
