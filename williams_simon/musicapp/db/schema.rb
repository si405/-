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

ActiveRecord::Schema.define(version: 20141016153624) do

  create_table "artists", force: true do |t|
    t.string   "artist_name"
    t.integer  "artist_age"
    t.integer  "label_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "artists", ["label_id"], name: "index_artists_on_label_id"

  create_table "labels", force: true do |t|
    t.string   "label_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "songs", force: true do |t|
    t.integer  "artist_id"
    t.string   "song_name"
    t.string   "genre"
    t.date     "release_date"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "songs", ["artist_id"], name: "index_songs_on_artist_id"

end
