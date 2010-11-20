class Price < ActiveRecord::Base
  
  belongs_to :cafeteria
  belongs_to :user
end
