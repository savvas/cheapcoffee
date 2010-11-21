class Cafeteria < ActiveRecord::Base
  include Geokit::Geocoders

  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lng

  has_many :suggested_prices
  belongs_to :user

  attr_accessor :approved, :voter_id, :slat, :slng, :dist, :telephone, :website
  validate :voted_already?

  before_save :approved?
  before_create :geocode!

  def voted_already?
    # check for the coffee type too
    suggested_price = self.suggested_prices.where(:user_id=>voter_id).where(:product=>approved).first
    errors.add(:base,"You have already voted") if suggested_price
  end

  def approved?
    if !self.approved.blank?
      votes_attr = "votes_#{self.approved.split('_')[1]}"
      self.send(votes_attr+"=", self.send(votes_attr)+1)
      # Create a new price suggestion
      SuggestedPrice.create!(:cafeteria_id=>self.id, :user_id=>voter_id, :product=>approved, :price=>self.send(approved))
    end
  end

  def geocode!
    if self.lat.blank?
        loc = Geocoder.google_geocoder("#{self.address}, #{self.city}")
        if loc.success
          self.lat, self.lng = loc.lat, loc.lng
        else
          errors.add(:base, "Could not geocode")
        end
    end
  end

end

