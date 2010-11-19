class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.openid_authenticatable
      t.integer :role_mask, :default => 1
      
      # current address
      t.string :current_address
      t.float :lat
      t.float :ltn
      
      # game
      t.integer :points, :default => 0
      
      # facebook data
      t.string :facebook_link
      t.string :facebook_access_token, :length => 85
      t.integer :facebook_uid, :length => 30
      t.string :name
      t.string :gender
      t.date :birthday
      t.text :friends_uids
      # voted cafeterias (in order not to have duplicate votes)
      t.text :voted_cafeterias_ids
      
      t.string :network, :size => 15, :default => "Facebook"
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      
      t.timestamps
    end
    
    add_index :users, :facebook_uid, :unique => true
    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :identity_url, :unique => true
    add_index :users, :facebook_uid, :unique => true
    add_index :users, :facebook_access_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :users
  end
end
