class SuggestedPricesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :xml, :json # class level

  # POST /suggested_prices
  # POST /suggested_prices.xml
  def create
    @suggested_price = SuggestedPrice.new(params[:suggested_price])
    @suggested_price.user_id = current_user.id

    respond_to do |format|
      if @suggested_price.save
        format.html { redirect_to(:controller=>"cafeterias", :action => "show", :id => @suggested_price.cafeteria_id, :notice => 'Thank you!') }
        format.xml  { render :xml => @suggested_price, :status => :created, :location => @cafeteria }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @suggested_price.errors, :status => :unprocessable_entity }
      end
    end
  end

end

