class User < ActiveRecord::Base
  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lng

  has_many :suggested_prices
  has_many :cafeterias

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :oauthable, :openid_authenticatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, 
                  :name, :sex, :birthday, :facebook_access_token, :facebook_uid

  scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }

  ROLES = %w[admin moderator customer]
  def roles=(roles)
     self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  #
  # Facebook related
  #
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = ActiveSupport::JSON.decode(access_token.get('https://graph.facebook.com/me?'))
    user = User.where(:email => data["email"]).first
    if user
      user.add_facebook_data!(data,access_token) if user.facebook_uid.blank?
      user
    else
      # Get friends
      # friends_data = facebook_session.graph.get_connections("me", "friends")
      # frids = ""
      # friends_data.each do |friend|
      #   frids += friend['id'].to_s+","
      # end
      
      # Create an user with a stub password.
      User.create!(:email => data["email"], :password => Devise.friendly_token[0..7],
        :name => data["name"], :birthday => data["birthday"],
        :facebook_uid => data["id"], :gender => data["gender"], :friends_uids => "",
        :network => "Facebook", :facebook_access_token => access_token.token)
    end
  end

  def add_facebook_data!(data,access_token)
    self.birthday = data["birthday"]
    self.gender = data["gender"]
    self.facebook_uid = data["facebook_uid"]
    self.facebook_access_token = access_token.token
    self.save
  end

  def geocode_me!
    loc = Geokit::Geocoders::MultiGeocoder.geocode(self.current_sign_in_ip)
    if loc
        self.lat, self.lng = loc.lat, loc.lng
        self.current_address = "#{loc.street_address}, #{loc.city}"
        self.save
    end
  end


end

