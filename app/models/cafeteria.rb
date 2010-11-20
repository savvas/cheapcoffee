class Cafeteria < ActiveRecord::Base
  has_many :suggested_prices
  belongs_to :user
  
  attr_accessor :approved, :voter_id
  validate :voted_already?
  before_save :approved?
  
  def voted_already?
    # check for the coffee type too
    suggested_prices = self.suggested_prices.where(:user_id=>voter_id).first
    errors.add_to_base("You have already voted") if suggested_prices && !suggested_prices.send(approved).nil?
  end
  
  def approved?
    if !self.approved.blank?
      votes_attr = "votes_#{self.approved.split('_')[1]}"
      self.send(votes_attr+"=", self.send(votes_attr)+1)
      # Check if the user has added or updated a price for a coffee of this cafeteria
      suggested_prices = self.suggested_prices.where(:user_id=>voter_id).first
      if suggested_prices
        # if yes then update the new coffee
        suggested_prices.send(approved+"=",self.send(approved))
        suggested_prices.save
      else
        # if no then create a price suggestion
        price = Price.new(:cafeteria_id=>self.id, :user_id=>voter_id)
        price.send(approved+"=",self.send(approved))
        price.save
      end
    end
  end
  
end
