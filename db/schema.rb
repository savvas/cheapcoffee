# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101119220641) do

  create_table "cafeterias", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.float    "lat"
    t.float    "ltn"
    t.integer  "user_id"
    t.integer  "likes"
    t.integer  "pageviews"
    t.float    "price_1"
    t.integer  "votes_1"
    t.float    "price_2"
    t.integer  "votes_2"
    t.float    "price_3"
    t.integer  "votes_3"
    t.float    "price_4"
    t.integer  "votes_4"
    t.float    "price_5"
    t.integer  "votes_5"
    t.float    "price_6"
    t.integer  "votes_6"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",    :limit => 128, :default => "", :null => false
    t.string   "password_salt",                        :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "facebook_uid",          :limit => 8
    t.string   "identity_url"
    t.string   "facebook_access_token"
    t.string   "current_address"
    t.float    "lat"
    t.float    "ltn"
    t.integer  "points",                               :default => 0
    t.string   "name"
    t.string   "sex"
    t.date     "birthday"
    t.text     "friends_uids"
    t.text     "voted_cafeterias_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["facebook_uid"], :name => "index_users_on_facebook_uid", :unique => true
  add_index "users", ["identity_url"], :name => "index_users_on_identity_url", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
