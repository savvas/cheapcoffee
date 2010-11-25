class User < ActiveRecord::Base
  require 'net/http'
  require 'net/https'
  
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
      # Get friends
      friends_data = facebook_session.graph.get_connections("me", "friends")
      frids = ""
      friends_data.each do |friend|
        frids += friend['id'].to_s+","
      end
      # Create an user with a stub password.
      User.create!(:email => data["email"], :password => Devise.friendly_token[0..7], 
               :name => data["name"], :birthday => data["birthday"],
               :facebook_uid => data["id"], :gender => data["gender"], :friends_uids => frids,
               :network=>"Facebook",:facebook_access_token=>access_token.token)
    end
  end
  
  def add_facebook_data!(data,token)
    user.birthday = data["birthday"]
    user.gender = data["gender"]
    user.facebook_uid = data["facebook_uid"]
    user.access_token = token
    user.save
  end
  
  
end
