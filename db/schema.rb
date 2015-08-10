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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150810030456) do

  create_table "events", force: :cascade do |t|
    t.integer  "source_id",           null: false
    t.string   "source_event_id",     null: false
    t.string   "title",               null: false
    t.text     "catchtext"
    t.text     "description"
    t.text     "detail_url",          null: false
    t.string   "hash_tag"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string   "pay_type"
    t.string   "event_type"
    t.text     "reference_url"
    t.integer  "limit"
    t.text     "adress"
    t.text     "place"
    t.string   "lat"
    t.string   "lon"
    t.string   "owner_id"
    t.text     "owner_profile_url"
    t.string   "owner_nickname"
    t.string   "owner_twitter_id"
    t.string   "owner_display_name"
    t.integer  "accepted"
    t.integer  "waiting"
    t.text     "banner"
    t.datetime "source_published_at"
    t.datetime "source_updated_at",   null: false
    t.string   "series_id"
    t.string   "series_title"
    t.string   "series_country_code"
    t.text     "series_logo"
    t.text     "series_description"
    t.text     "series_url"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

end
