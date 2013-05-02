# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20111010131120) do

  create_table "blog_entries", :force => true do |t|
    t.string   "subject"
    t.text     "content"
    t.datetime "publish_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_names", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.string   "file"
    t.text     "comment"
    t.integer  "sport_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "distance"
    t.integer  "trainings_id"
  end

  create_table "downloads", :force => true do |t|
    t.string   "name"
    t.string   "file"
    t.text     "comment"
    t.integer  "sport_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "laps", :force => true do |t|
    t.integer  "trainings_id"
    t.float    "distance_total"
    t.float    "heartrate_max"
    t.float    "calories"
    t.integer  "heartrate_avg"
    t.float    "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "training_id"
    t.text     "map"
    t.text     "heartrate"
    t.text     "height"
    t.datetime "start_time"
  end

  create_table "posts", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sport_levels", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "css"
    t.integer  "sort"
  end

  create_table "sports", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order"
  end

  create_table "trainings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "sport_id"
    t.integer  "sport_level_id"
    t.integer  "course_name_id"
    t.float    "time_total"
    t.float    "distance_total"
    t.text     "map_data"
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_time"
    t.text     "heartrate"
    t.text     "height"
    t.text     "comment"
    t.integer  "heartrate_avg"
    t.integer  "heartrate_max"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",                  :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "role_id"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
