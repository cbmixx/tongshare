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

ActiveRecord::Schema.define(:version => 20110322123552) do

  create_table "acceptances", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.boolean  "decision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "acceptances", ["event_id"], :name => "index_acceptances_on_event_id"
  add_index "acceptances", ["user_id", "event_id"], :name => "acceptances_user_event_index"
  add_index "acceptances", ["user_id"], :name => "index_acceptances_on_user_id"

  create_table "admin_extras", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "admin_enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id"
    t.string   "mark"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consumer_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",       :limit => 30
    t.string   "token",      :limit => 128
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "consumer_tokens", ["token"], :name => "index_consumer_tokens_on_token", :unique => true

  create_table "events", :force => true do |t|
    t.string   "name"
    t.datetime "begin"
    t.datetime "end"
    t.string   "location"
    t.text     "extra_info"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rrule"
    t.string   "share_token"
  end

  add_index "events", ["begin"], :name => "index_events_on_begin"
  add_index "events", ["creator_id"], :name => "index_events_on_creator_id"
  add_index "events", ["end"], :name => "index_events_on_end"
  add_index "events", ["updated_at"], :name => "index_events_on_updated_at"

  create_table "feedbacks", :force => true do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedbacks", ["instance_id"], :name => "index_feedbacks_on_instance_id"
  add_index "feedbacks", ["user_id"], :name => "index_feedbacks_on_user_id"

  create_table "group_sharings", :force => true do |t|
    t.integer  "sharing_id"
    t.integer  "group_id"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "extra_info"
    t.string   "identifier"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instances", :force => true do |t|
    t.string   "name"
    t.datetime "begin"
    t.datetime "end"
    t.string   "location"
    t.text     "extra_info"
    t.integer  "event_id"
    t.integer  "index"
    t.boolean  "override"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
  end

  add_index "instances", ["begin"], :name => "index_instances_on_begin"
  add_index "instances", ["creator_id"], :name => "index_instances_on_creator_id"
  add_index "instances", ["end"], :name => "index_instances_on_end"
  add_index "instances", ["event_id"], :name => "index_instances_on_event_id"

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.integer  "power"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reminder_queues", :force => true do |t|
    t.datetime "time"
    t.integer  "method_type"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reminder_id"
  end

  create_table "reminders", :force => true do |t|
    t.integer  "method_type"
    t.integer  "value"
    t.integer  "time_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

  create_table "sharings", :force => true do |t|
    t.integer  "event_id"
    t.integer  "shared_from"
    t.text     "extra_info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sharings", ["event_id"], :name => "index_sharings_on_event_id"
  add_index "sharings", ["shared_from"], :name => "index_sharings_on_shared_from"

  create_table "user_extras", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "mobile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",              :default => false
    t.string   "renren_id"
    t.boolean  "reject_warning_flag"
  end

  add_index "user_extras", ["name"], :name => "index_user_extras_on_name"
  add_index "user_extras", ["user_id"], :name => "index_user_extras_on_user_id"

  create_table "user_identifiers", :force => true do |t|
    t.string   "login_value"
    t.integer  "user_id"
    t.string   "login_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirmed",   :default => false
  end

  add_index "user_identifiers", ["confirmed"], :name => "index_user_identifiers_on_confirmed"
  add_index "user_identifiers", ["login_type", "login_value"], :name => "index_user_identifiers_on_type_and_value", :unique => true
  add_index "user_identifiers", ["user_id"], :name => "index_user_identifiers_on_user_id"

  create_table "user_sharings", :force => true do |t|
    t.integer  "sharing_id"
    t.integer  "user_id"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_sharings", ["priority"], :name => "index_user_sharings_on_priority"
  add_index "user_sharings", ["sharing_id"], :name => "index_user_sharings_on_sharing_id"
  add_index "user_sharings", ["user_id"], :name => "index_user_sharings_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
