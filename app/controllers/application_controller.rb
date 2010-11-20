class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :generate_product_pricelist
  
  
  
  
  def generate_product_pricelist
    @price_list = [
      {
        :field_name => 'price_1',
        :name => 'Frappe'
      }, 
      {
        :field_name => 'price_1',
        :name => 'Espresso'
      }, 
      {
        :field_name => 'price_1',
        :name => 'Espresso Freddo'
      }, 
      {
        :field_name  => 'price_1',
        :name => 'Cappuccino'
      }, 
      {
        :field_name => 'price_1',
        :name => 'Freddo Cappuccino'
      }, 
      {
        :field_name => 'price_1',
        :name => 'Greek Coffee'
      }
    ]
  end
end
