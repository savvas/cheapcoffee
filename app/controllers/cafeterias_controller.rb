class CafeteriasController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  respond_to :html, :xml, :json # class level

  # GET /cafeterias
  # GET /cafeterias.xml
  def index
    @cafeterias = Cafeteria.limit(6)
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
    # get cafeterias in a short distance
    _update_current_user_location!
    @existing = Cafeteria.within(0.25, :origin => current_user)
    # reverse geocode
    geostr = "#{current_user.lat},#{current_user.lng}"
    res = Rails.cache.fetch(geostr){ Geokit::Geocoders::GoogleGeocoder.reverse_geocode(geostr) }

    @cafeteria = Cafeteria.new
    @cafeteria.address = res.street_address
    @cafeteria.city = res.city
    @cafeteria.lat = res.lat
    @cafeteria.lng = res.lng

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

  def approve
    @cafeteria = Cafeteria.find(params[:id])
    @cafeteria.approved = params[:approved]
    @cafeteria.voter_id = current_user.id
    if @cafeteria.save
      format.html { redirect_to @cafeteria, :notice => "Thanks!" }
      format.json { render :text => 1 }
    else
      format.html { redirect_to @cafeteria, :error => @cafeteria.errors }
      format.json { render :text => -1 }
    end
  end

  def blame
    # Blame price_x for cafeteria_id
    @cafeteria = Cafeteria.find(params[:id])
    @product = params[:blamed]
    # cache it god damn it
    @top3 = SuggestedPrice.find_by_sql("SELECT price, COUNT(*) as freq FROM suggested_prices "+
                                       "WHERE cafeteria_id=#{@cafeteria.id} AND product='#{@product}'" +
                                       " GROUP BY price ORDER BY freq DESC LIMIT 3")
  end


  def search
    _update_current_user_location!
    # Do the search!
    if params[:corner_up]
      @cafeterias = Cafeteria.in_bounds([params[:corner_up], params[:corner_down]], :origin => current_user)
    else
      # Search queries
      range = params[:range].present? ? params[:range].to_i : 2
      @cafeterias = Cafeteria.within(range, :origin => current_user)
    end
    product = "price_1" # change from params
    @cafeterias = @cafeterias.order("#{product} DESC")
    respond_with(@cafeterias)
  end

  def _update_current_user_location!
    # if there is no session and no params
    if session[:lat].blank? && params[:lat].blank?
      current_user.geocode_me!
      session[:lat], session[:lng] = current_user.lat, current_user.lng
    # if we have params from mobile or browser then update
    elsif !params[:lat].blank?
      session[:lat], session[:lng] = params[:lat], params[:lng]
      current_user.lat = session[:lat]
      current_user.lng = session[:lng]
    # if only session is present then use the sessio data
    else
      current_user.lat, current_user.lng = session[:lat], session[:lng]
    end
  end

end

