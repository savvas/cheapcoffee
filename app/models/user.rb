class User < ActiveRecord::Base
  require 'net/http'
  require 'net/https'
  
  has_many :prices
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :oauthable, :openid_authenticatable
    
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :sex, :birthday
  
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
    if user = User.where(:email => data["email"]).first
      user.add_facebook_data!(data,access_token.token) if user.facebook_uid.blank?
      user
    else
      # Create an user with a stub password.
      User.create!(:email => data["email"], :password => Devise.friendly_token[0..7], 
               :name => data["name"], :birthday => data["birthday"],
               :facebook_uid => data["id"], :gender => data["gender"],
               :network=>"Facebook",:access_token=>access_token.token)
    end
  end
  
  def add_facebook_data!(data,token)
    self.birthday = data["birthday"]
    self.gender = data["gender"]
    self.facebook_uid = data["facebook_uid"]
    self.facebook_access_token = token
    self.save
  end
  
  
end
