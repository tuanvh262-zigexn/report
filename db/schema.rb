# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_20_095502) do
  create_table "report_tasks", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "team_report_id", null: false
    t.bigint "sub_task_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sub_task_id"], name: "index_report_tasks_on_sub_task_id"
    t.index ["team_report_id"], name: "index_report_tasks_on_team_report_id"
  end

  create_table "stories", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "issue_id"
    t.integer "status", default: 0, null: false
    t.integer "level"
    t.string "subject"
    t.date "start_date"
    t.date "due_date"
    t.decimal "time_estimate_ratio", precision: 10, scale: 2
    t.decimal "total_estimated_hours", precision: 10, scale: 2
    t.decimal "total_spent_hours", precision: 10, scale: 2
    t.integer "test_case_count", default: 0
    t.integer "bug_count", default: 0
    t.integer "prod_bug_count", default: 0
    t.integer "done_ratio", default: 0
    t.integer "timecrowd_est_ratio", default: 0
    t.date "requirement_start_at"
    t.date "requirement_end_at"
    t.date "design_start_at"
    t.date "design_end_at"
    t.date "coding_start_at"
    t.date "coding_end_at"
    t.date "testing_start_at"
    t.date "testing_end_at"
    t.date "bug_fixing_start_at"
    t.date "bug_fixing_end_at"
    t.decimal "requirement_hours", precision: 10, scale: 2
    t.decimal "design_hours", precision: 10, scale: 2
    t.decimal "coding_hours", precision: 10, scale: 2
    t.decimal "testing_hours", precision: 10, scale: 2
    t.decimal "bug_fixing_hours", precision: 10, scale: 2
    t.decimal "release_hours", precision: 10, scale: 2
    t.decimal "cross_support_hours", precision: 10, scale: 2
    t.decimal "time_crowd_est_hours", precision: 10, scale: 2
    t.date "finished_at"
    t.datetime "redmine_created_at"
    t.datetime "redmine_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_stories_on_issue_id", unique: true
    t.index ["user_id"], name: "index_stories_on_user_id"
  end

  create_table "sub_tasks", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "story_id"
    t.bigint "owner_id"
    t.integer "issue_id"
    t.integer "status", default: 0, null: false
    t.string "kind", null: false
    t.string "subject"
    t.date "start_date"
    t.date "due_date"
    t.integer "done_ratio", default: 0
    t.decimal "time_estimate_ratio", precision: 10, scale: 2
    t.decimal "total_estimated_hours", precision: 10, scale: 2
    t.decimal "total_spent_hours", precision: 10, scale: 2
    t.boolean "is_bug"
    t.integer "bug_category", default: 0
    t.integer "defect_origin", default: 0
    t.boolean "meet_deadline", default: false
    t.boolean "update_title", default: false
    t.integer "activity_type"
    t.datetime "redmine_created_at"
    t.datetime "redmine_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_sub_tasks_on_issue_id", unique: true
    t.index ["owner_id"], name: "index_sub_tasks_on_owner_id"
    t.index ["story_id"], name: "index_sub_tasks_on_story_id"
  end

  create_table "team_reports", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.string "type", null: false
    t.json "content", null: false
    t.date "start_date", null: false
    t.boolean "latest", default: false
    t.boolean "public", default: false
    t.decimal "total_time_working", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type", "user_id", "start_date"], name: "index_team_reports_on_type_and_user_id_and_start_date", unique: true
    t.index ["user_id"], name: "index_team_reports_on_user_id"
  end

  create_table "time_crowd_tasks", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "story_id"
    t.integer "time_crowd_id"
    t.string "total_time"
    t.integer "total_second"
    t.json "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id", "time_crowd_id"], name: "index_time_crowd_tasks_on_story_id_and_time_crowd_id", unique: true
    t.index ["story_id"], name: "index_time_crowd_tasks_on_story_id"
  end

  create_table "user_working_logs", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "hours", precision: 10, scale: 2, null: false
    t.integer "activity_type", default: 0, null: false
    t.boolean "standardized", default: false
    t.date "spent_on", null: false
    t.string "activity", null: false
    t.integer "issue_id", null: false
    t.string "project_name", null: false
    t.string "comments"
    t.integer "root_issue_id"
    t.boolean "owner_issue", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_working_logs_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.integer "redmine_id"
    t.integer "role"
    t.boolean "actived"
    t.boolean "part_time", default: false
    t.float "buffer_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["redmine_id"], name: "index_users_on_redmine_id", unique: true
  end
end
