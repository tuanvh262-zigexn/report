class Story::FetchService
  attr_accessor :redmine_issue_id, :redis, :redis_key, :options

  def initialize redmine_issue_id, options = {}
    @redmine_issue_id = redmine_issue_id
    @redis = Redis.new(
      host: Settings.redis.host,
      port: Settings.redis.port,
      db: Settings.redis.db
    )
    @redis_key = "#{Settings.redis.key.fetch_story}_#{redmine_issue_id}"
    @options = options
  end

  def execute
    unless options[:force_update]
      return unless redis.setnx(redis_key, Time.current.to_i)
      redis.getex(redis_key, ex: Settings.redis.expried.story)
      user_changed = false
    end

    ActiveRecord::Base.transaction do
      story.assign_attributes(
        user_id: user&.id,
        status: status,
        level: level,
        time_crowd_est: timecrowd_est,
        subject: redmine_issue.dig("subject"),
        start_date: redmine_issue.dig("start_date"),
        due_date: redmine_issue.dig("due_date"),
        done_ratio: redmine_issue.dig("done_ratio").to_i,
        total_estimated_hours: redmine_issue.dig("total_estimated_hours"),
        total_spent_hours: redmine_issue.dig("total_spent_hours"),
        time_estimate_ratio: time_estimate_ratio,
        test_case_count: redmine_issue_test["custom_fields"]
          &.find{|x| x["name"] == "Number of test cases"}.try("[]", "value").to_i,
        bug_count: redmine_issue_test["custom_fields"]
          &.find{|x| x["name"] == "STG Bugs (VN)"}.try("[]", "value").to_i,
        prod_bug_count: redmine_issue_test["custom_fields"]
          &.find{|x| x["name"] == "Production Bugs"}.try("[]", "value").to_i,
        requirement_start_at: requirement_logs.map(&:spent_on).first,
        requirement_end_at: requirement_logs.map(&:spent_on).last,
        design_start_at: design_logs.map(&:spent_on).first,
        design_end_at: design_logs.map(&:spent_on).last,
        coding_start_at: coding_logs.map(&:spent_on).first,
        coding_end_at: coding_logs.map(&:spent_on).last,
        testing_start_at: testing_logs.map(&:spent_on).first,
        testing_end_at: testing_logs.map(&:spent_on).last,
        bug_fixing_start_at: bug_fixing_logs.map(&:spent_on).first,
        bug_fixing_end_at: bug_fixing_logs.map(&:spent_on).last,
        requirement_hours: requirement_logs.sum(&:hours),
        design_hours: design_logs.sum(&:hours),
        coding_hours: coding_logs.sum(&:hours),
        testing_hours: testing_logs.sum(&:hours),
        bug_fixing_hours: bug_fixing_logs.sum(&:hours),
        release_hours: release_logs.sum(&:hours),
        cross_support_hours: cross_support_logs.sum(&:hours),
        finished_at: finished_at,
        redmine_created_at: redmine_issue.dig("created_on")&.to_datetime,
        redmine_updated_at:redmine_issue.dig("updated_on")&.to_datetime,
        timecrowd_est_ratio: timecrowd_est_ratio,
        request_from_jp: request_from_jp?
      )

      user_changed = story.user_id_changed? || story.level_changed?
      story.save!
      build_sub_tasks!
      remove_sub_tasks!

      story.sub_tasks.each do |task|
        FetchSubTaskWorker.perform_async(task.id, options[:force_update])
      end

      if user_changed
        story.working_logs.each do |log|
          CategorizeActivitiesUserWorkingLogWorker.perform_async(log.id)
        end
      end
    rescue StandardError => e
      redis.del(redis_key)
      raise e.class, "Message: #{e.message}"
    end
  end

  private

  def story
    @story ||= Story.find_or_initialize_by(issue_id: redmine_issue_id)
  end

  def redmine_issue
    @redmine_issue ||= Redmine::Issue.new(redmine_issue_id, !options[:force_update]).execute
  end

  def redmine_issue_test
    @redmine_issue_test ||= begin
      issue_test_id = redmine_issue["children"]&.find{|x| x.dig("tracker", "id") == 9}&.dig("id")
      return {} if issue_test_id.nil?
      Redmine::Issue.new(issue_test_id).execute
    end
  end

  def sub_tasks
    @sub_tasks ||= begin
      return [] unless redmine_issue["children"]
      unless request_from_jp?
        return redmine_issue["children"]
      end
      redmine_issue["children"].map{|x| x&.try("[]", "children")}.compact.flatten
    end
  end

  def working_logs
    @working_logs ||= begin
      story.working_logs.order(:spent_on).to_a
    end
  end

  def finished_at
    return if status < 6
    working_logs.last&.spent_on
  end

  def requirement_logs
    @requirement_logs ||= working_logs.select{|x| x.activity_type == "requirement"}
  end

  def design_logs
    @design_logs ||= working_logs.select{|x| x.owner_issue && x.activity_type == "design"}
  end

  def coding_logs
    @coding_logs ||= working_logs.select{|x| x.owner_issue && x.activity_type == "coding"}
  end

  def testing_logs
    @testing_logs ||= working_logs.select{|x| x.activity_type == "testing"}
  end

  def bug_fixing_logs
    @bug_fixing_logs ||= working_logs.select{|x| x.owner_issue && x.activity_type == "bug_fixing"}
  end

  def release_logs
    @release_logs ||= working_logs.select{|x| x.activity_type == "release"}
  end

  def cross_support_logs
    @cross_support_logs ||= working_logs.reject{|x| x.owner_issue}
  end

  def tracker_mapping
    @tracker_mapping ||= begin
      sub_tasks.reduce({}) { |h, v| h.merge({v["id"] => v.dig("tracker", "name").downcase}) }
    end
  end

  def build_sub_tasks!
    (sub_tasks.map{|x| x["id"]} - story.sub_tasks.pluck(:issue_id)).each do |x|
      SubTask.create! issue_id: x, story_id: story.id, kind: tracker_mapping[x]
    end
  end

  def remove_sub_tasks!
    (story.sub_tasks.pluck(:issue_id) - sub_tasks.map{|x| x["id"]}).each do |x|
      SubTask.find_by(issue_id: x).destroy!
    end
  end

  def user
    @user ||= User.find_by(redmine_id: user_redmine_id)
  end

  def user_redmine_id
    redmine_issue.dig("assigned_to", "id")
  end

  def status
    @status ||= Story.statuses[redmine_issue.dig("status", "name").downcase.gsub(" ", "_")] || 0
  end

  def level
    redmine_issue.dig("custom_fields").find{|x| x["name"] == "Difficulty Level"}.try("[]", "value").to_i
  end

  def request_from_jp?
    redmine_issue.dig("custom_fields").find{|x| x["name"] == "JP Request"}.try("[]", "value") != "none"
  end

  def timecrowd_est
    @timecrowd_est ||= begin
      data = redmine_issue.dig("custom_fields")
        .find{|x| x["name"] == "Timecword Estimate Hours"}.try("[]", "value")
        &.split(",") || []

      {
        investigate: data[0].to_i || 0,
        design: data[1].to_i || 0,
        coding: data[2].to_i || 0,
        testing: data[3].to_i || 0,
      }
    end
  end

  def time_estimate_ratio
    return 0 if redmine_issue.dig("total_estimated_hours").to_i.zero?
    redmine_issue.dig("total_spent_hours") / redmine_issue.dig("total_estimated_hours")
  end

  def timecrowd_est_ratio
    return 0 if story.time_crowd_tasks.empty? || timecrowd_est.values.all?(&:zero?)

    story.time_crowd_tasks.map do |x|
      if timecrowd_est[x.activity_type.to_sym].zero?
        0
      else
        x.total_second / (timecrowd_est[x.activity_type.to_sym] * 3600) * 100
      end
    end.max
  end
end
