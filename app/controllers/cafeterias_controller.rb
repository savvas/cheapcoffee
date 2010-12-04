class CafeteriasController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit, :create, :update, :destroy, :approve, :blame]
  respond_to :html, :xml, :json # class level

  def index; end

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

    @cafeteria = Cafeteria.new
    begin
        res = Rails.cache.fetch(geostr){ Geokit::Geocoders::GoogleGeocoder.reverse_geocode(geostr) }
        @cafeteria.address = res.street_address
        @cafeteria.city = res.city
        @cafeteria.lat = res.lat
        @cafeteria.lng = res.lng
    rescue
        logger.error("No Geocode")
    end

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
        flash[:error] = @cafeteria.errors
        redirect_to root_path
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
  
  def reverse_geocode
    res = Rails.cache.fetch(params[:pair]){ Geokit::Geocoders::GoogleGeocoder.reverse_geocode(params[:pair]) }
    render :text => "#{res.street_address} * #{res.city}"
  rescue
    render :text => "*"
  end

  def geocode
    loc = Rails.cache.fetch(params[:search]){ Geokit::Geocoders::Geocoder.google_geocoder("#{params[:search]}") }
    render :text => "#{loc.lat},#{loc.lng}"
  rescue
    render :text => "0,0"
  end

  def search
    _update_current_user_location_session!

    if params[:sw_lat]
      sw_point = GeoKit::LatLng.new(params[:sw_lat],params[:sw_lng])
      ne_point = GeoKit::LatLng.new(params[:ne_lat],params[:ne_lng])
      bounds = GeoKit::Bounds.new(sw_point,ne_point)
      cafeterias = Cafeteria.in_bounds(bounds, :origin => [session[:c_lat], session[:c_lng]])
    else
      # Search queries
      range = params[:range].present? ? params[:range].to_i : 1
      cafeterias = Cafeteria.within(range, :origin => [session[:c_lat], session[:c_lng]])
    end
    # more search params
    product = params[:product] || "price_1" # change from params search
    cafeterias = cafeterias.order("#{product} ASC")
    cafeterias = cafeterias.limit(20)
    
    # create a hash
    @cafeterias = cafeterias.collect do |c|
       {'cafeteria'=>{ 'id'=>c.id, 'name'=>c.name, 'address'=>c.address,'price_1'=>c.price_1,
        'lat'=>c.lat, 'lng' => c.lng, 'distance' => c.distance[0..3].to_f }}
    end

    respond_with(@cafeterias)
  end

  private
  def _update_current_user_location_session!
    # if there is no session and no params
    if session[:c_lat].blank? && params[:c_lat].blank?
      current_ip = current_user ? current_user.current_sign_in_ip : request.remote_ip 
      loc = Geokit::Geocoders::MultiGeocoder.geocode(current_ip)
      if loc
        session[:c_lat], session[:c_lng] = loc.lat, loc.lng
      else
        # use some defaults
      end
      cookies[:c_lat], cookies[:c_lng] = session[:c_lat], session[:c_lng]
    # if we have params from mobile or browser then update
    elsif !params[:c_lat].blank?
      session[:c_lat], session[:c_lng] = params[:c_lat], params[:c_lng]
      cookies[:c_lat], cookies[:c_lng] = session[:c_lat], session[:c_lng] # set a cookie so we do not detect the user again
    end
  end

end

