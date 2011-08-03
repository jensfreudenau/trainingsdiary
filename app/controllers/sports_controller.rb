class SportsController < ApplicationController
    # GET /sports
    # GET /sports.xml
    before_filter :authenticate_user!, :except => [:sort]
    def index
        #@sports = Sport.find(
        #        :all,
        #         
        #        :conditions => {:user_id => current_user.id }
        #        )
        @log = Logger.new('log/sport.log')
        @sports = Sport.with_exclusive_scope { find(:all) }
        @log.debug(@sports)
        respond_to do |format|
            format.html # index.html.erb
            format.xml  { render :xml => @sports }
        end
    end
    
    # GET /sports/1
    # GET /sports/1.xml
    def show
        @sport = Sport.find(:first, :conditions => {:user_id => current_user.id, :id => params[:id]})
        
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @sport }
        end
    end
    
    # GET /sports/new
    # GET /sports/new.xml
    def new
        @sport = Sport.new
        
        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => @sport }
        end
    end
    
    # GET /sports/1/edit
    def edit
        @sport = Sport.find(:first,
                            :conditions => {:user_id => current_user.id , :id => params[:id]})
    end
    
    # POST /sports
    # POST /sports.xml
    def create
        #@sport = Sport.new(params[:sport])
        params[:sport][:user_id] = current_user.id
		    @sport = current_user.sports.new(params[:sport])
        respond_to do |format|
            if @sport.save
                format.html { redirect_to(sports_url, :notice => 'Sport was successfully created.') }
                format.xml  { render :xml => @sport, :status => :created, :location => @sport }
                format.js
                else
                format.html { render :action => "new" }
                format.xml  { render :xml => @sport.errors, :status => :unprocessable_entity }
                format.js
            end
        end
    end
    
    # PUT /sports/1
    # PUT /sports/1.xml
    def update
        @sport = Sport.find(:first,
                            :conditions => {:user_id => current_user.id , :id => params[:id]})
        
        respond_to do |format|
            if @sport.update_attributes(params[:sport])
                format.html { redirect_to(sports_url, :notice => 'Sport was successfully updated.') }
                format.xml  { head :ok }
                else
                format.html { render :action => "edit" }
                format.xml  { render :xml => @sport.errors, :status => :unprocessable_entity }
            end
        end
    end
    
    # DELETE /sports/1
    # DELETE /sports/1.xml
    def destroy
        @sport = Sport.find(params[:id])
        @sport.destroy
        
        respond_to do |format|
            format.html { redirect_to(sports_url, :notice => 'Sport was successfully deleted.') }
            format.xml  { head :ok }
        end
    end
    
    def sort
      @sports = Sport.all
      @sports.each do |sport|
        sport.sort = params[:list].index(sport.id.to_s)
        sport.save
      end 
      render :nothing => true 
    end
end
