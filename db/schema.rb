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

ActiveRecord::Schema.define(version: 20150721062609) do

  create_table "builds", force: true do |t|
    t.integer  "repo_id"
    t.string   "action"
    t.integer  "number"
    t.string   "head_sha"
    t.string   "head_repo_full_name"
    t.string   "head_ssh_url"
    t.string   "base_sha"
    t.string   "base_repo_full_name"
    t.string   "base_ssh_url"
    t.string   "title"
    t.string   "html_url"
    t.integer  "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "results"
  end

  add_index "builds", ["repo_id"], name: "index_builds_on_repo_id"

  create_table "repos", force: true do |t|
    t.string   "full_name"
    t.boolean  "private"
    t.string   "html_url"
    t.boolean  "active",           default: false
    t.integer  "user_id"
    t.integer  "hook_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ssh_url"
    t.integer  "stargazers_count"
    t.string   "language"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "name"
    t.string   "avatar"
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
