class PagesController < ApplicationController


  def about
    render :action => "about"
  end

  def faq
    render :action => "faq"
  end


  def contact
    render :action => "contact"
  end
  
end

