class CafeteriasController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :xml, :json # class level
  
  # GET /cafeterias
  # GET /cafeterias.xml
  def index
    @cafeterias = Cafeteria.all
    respond_with(@cafeterias)
  end

  # GET /cafeterias/1
  # GET /cafeterias/1.xml
  def show
    @cafeteria = Cafeteria.find(params[:id])
    respond_with(@cafeteria)
  end

  # GET /cafeterias/new
  # GET /cafeterias/new.xml
  def new
    @cafeteria = Cafeteria.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cafeteria }
    end
  end

  # GET /cafeterias/1/edit
  def edit
    @cafeteria = Cafeteria.find(params[:id])
  end

  # POST /cafeterias
  # POST /cafeterias.xml
  def create
    @cafeteria = Cafeteria.new(params[:cafeteria])

    respond_to do |format|
      if @cafeteria.save
        format.html { redirect_to(:action => "index", :notice => 'Cafeteria was successfully created.') }
        format.xml  { render :xml => @cafeteria, :status => :created, :location => @cafeteria }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cafeteria.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cafeterias/1
  # PUT /cafeterias/1.xml
  def update
    @cafeteria = Cafeteria.find(params[:id])

    respond_to do |format|
      if @cafeteria.update_attributes(params[:cafeteria])
        format.html { redirect_to(@cafeteria, :notice => 'Cafeteria was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cafeteria.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cafeterias/1
  # DELETE /cafeterias/1.xml
  def destroy
    @cafeteria = Cafeteria.find(params[:id])
    @cafeteria.destroy

    respond_to do |format|
      format.html { redirect_to(cafeterias_url) }
      format.xml  { head :ok }
    end
  end
end
