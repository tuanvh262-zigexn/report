class Reports::IndexSupport
  attr_accessor :params_q

  def initialize params_q
    @params_q = params_q || {}
  end

  def story_chart
    reports.map do |report|
      stories = report.stories.uniq.to_a
      {
        title: report.start_date.strftime("%d/%m/%y"),
        total_tasks: stories.size,
        waiting_release: stories.select{|x| ['waiting_release', 'verified', 'jp_side'].include?(x.status)}.size,
        released: stories.select{|x| ['closed', 'released'].include?(x.status)}.size,
      }
    end
  end

  def params_search
    @params_search ||= begin
      {
        start_date: params_q.dig(:start_date)&.to_date || (Date.current - 2.months).beginning_of_week,
        end_date: params_q.dig(:end_date)&.to_date || Date.current,
        report_type: params_q.dig(:report_type) || "weekly_report",
        user_id: params_q.dig(:user_id).presence
      }
    end
  end

  def pie_chart_working_logs
    {
      idle: reports.sum{|x| x.content["idle"]},
      meeting: reports.sum{|x| x.content["meeting"]},
      document: reports.sum{|x| x.content["document"]},
      leave_off: reports.sum{|x| x.content["leave_off"]},
      cross_review: reports.sum{|x| x.content["support_team"]},
      support_customer: reports.sum{|x| x.content["support_customer"]},
      doing_task: reports.sum{|x| x.content["doing_task"]},
      other: reports.sum{|x| x.content["not_found"]}
    }
  end

  def pie_chart_detail_working_logs
    {
      requirement: reports.sum{|x| x.content["requirement"]},
      design: reports.sum{|x| x.content["design"]},
      coding: reports.sum{|x| x.content["coding"]},
      testing: reports.sum{|x| x.content["testing"]},
      bug_fixing: reports.sum{|x| x.content["bug_fixing"]},
      release: reports.sum{|x| x.content["release"]}
    }
  end

  def task_chart
    reports.map do |report|
      tasks = report.tasks.uniq.to_a
      {
        title: report.start_date.strftime("%d/%m/%y"),
        total: tasks.size,
        done_tasks: tasks.select{|x| ['closed', 'released'].include?(x.status)}.size,
        meeting_deadline: tasks.select{|x| x.meet_deadline}.size
      }
    end
  end

  def bug_chart
    reports.map do |report|
      tasks = report.tasks.uniq.to_a
      stories = report.stories.uniq.to_a
      {
        title: report.start_date.strftime("%d/%m/%y"),
        total: tasks.select(&:is_bug).size,
        testcases: stories.sum(&:test_case_count),
        prod_bugs: stories.sum(&:prod_bug_count),
      }
    end
  end

  def tester_workload_chart
    reports.map do |report|
      stories = report.stories.uniq.to_a
      {
        title: report.start_date.strftime("%d/%m/%y"),
        testcases: stories.sum(&:test_case_count),
        testing_hours: stories.sum(&:testing_hours)
      }
    end
  end

  def difficulty_chart
    reports.map do |report|
      stories = report.stories.uniq.to_a
      {
        title: report.start_date.strftime("%d/%m/%y"),
        unset: stories.select(&:unset?).sum(&:requirement_hours) +
          stories.select(&:unset?).sum(&:design_hours) +
          stories.select(&:unset?).sum(&:coding_hours) +
          stories.select(&:unset?).sum(&:testing_hours) +
          stories.select(&:unset?).sum(&:bug_fixing_hours) +
          stories.select(&:unset?).sum(&:release_hours),
        basic: stories.select(&:basic?).sum(&:requirement_hours) +
          stories.select(&:basic?).sum(&:design_hours) +
          stories.select(&:basic?).sum(&:coding_hours) +
          stories.select(&:basic?).sum(&:testing_hours) +
          stories.select(&:basic?).sum(&:bug_fixing_hours) +
          stories.select(&:basic?).sum(&:release_hours),
        intermediate: stories.select(&:intermediate?).sum(&:requirement_hours) +
          stories.select(&:intermediate?).sum(&:design_hours) +
          stories.select(&:intermediate?).sum(&:coding_hours) +
          stories.select(&:intermediate?).sum(&:testing_hours) +
          stories.select(&:intermediate?).sum(&:bug_fixing_hours) +
          stories.select(&:intermediate?).sum(&:release_hours),
        upper_intermediate: stories.select(&:upper_intermediate?).sum(&:requirement_hours) +
          stories.select(&:upper_intermediate?).sum(&:design_hours) +
          stories.select(&:upper_intermediate?).sum(&:coding_hours) +
          stories.select(&:upper_intermediate?).sum(&:testing_hours) +
          stories.select(&:upper_intermediate?).sum(&:bug_fixing_hours) +
          stories.select(&:upper_intermediate?).sum(&:release_hours),
        advanced: stories.select(&:advanced?).sum(&:requirement_hours) +
          stories.select(&:advanced?).sum(&:design_hours) +
          stories.select(&:advanced?).sum(&:coding_hours) +
          stories.select(&:advanced?).sum(&:testing_hours) +
          stories.select(&:advanced?).sum(&:bug_fixing_hours) +
          stories.select(&:advanced?).sum(&:release_hours),
        expert: stories.select(&:expert?).sum(&:requirement_hours) +
          stories.select(&:expert?).sum(&:design_hours) +
          stories.select(&:expert?).sum(&:coding_hours) +
          stories.select(&:expert?).sum(&:testing_hours) +
          stories.select(&:expert?).sum(&:bug_fixing_hours) +
          stories.select(&:expert?).sum(&:release_hours)
      }
    end
  end

  def difficulty_coding_chart
    reports.map do |report|
      stories = report.stories.uniq.to_a
      {
        title: report.start_date.strftime("%d/%m/%y"),
        unset: stories.select(&:unset?).sum(&:bug_fixing_hours) +
          stories.select(&:unset?).sum(&:design_hours) +
          stories.select(&:unset?).sum(&:coding_hours),
        basic: stories.select(&:basic?).sum(&:bug_fixing_hours) +
          stories.select(&:basic?).sum(&:design_hours) +
          stories.select(&:basic?).sum(&:coding_hours),
        intermediate: stories.select(&:intermediate?).sum(&:bug_fixing_hours) +
          stories.select(&:intermediate?).sum(&:design_hours) +
          stories.select(&:intermediate?).sum(&:coding_hours),
        upper_intermediate: stories.select(&:upper_intermediate?).sum(&:bug_fixing_hours) +
          stories.select(&:upper_intermediate?).sum(&:design_hours) +
          stories.select(&:upper_intermediate?).sum(&:coding_hours),
        advanced: stories.select(&:advanced?).sum(&:bug_fixing_hours) +
          stories.select(&:advanced?).sum(&:design_hours) +
          stories.select(&:advanced?).sum(&:coding_hours),
        expert: stories.select(&:expert?).sum(&:bug_fixing_hours) +
          stories.select(&:expert?).sum(&:design_hours) +
          stories.select(&:expert?).sum(&:coding_hours)
      }
    end
  end

  def difficulty_testing_chart
    reports.map do |report|
      stories = report.stories.uniq.to_a
      {
        title: report.start_date.strftime("%d/%m/%y"),
        unset: stories.select(&:unset?).sum(&:testing_hours),
        basic: stories.select(&:basic?).sum(&:testing_hours),
        intermediate: stories.select(&:intermediate?).sum(&:testing_hours),
        upper_intermediate: stories.select(&:upper_intermediate?).sum(&:testing_hours),
        advanced: stories.select(&:advanced?).sum(&:testing_hours),
        expert: stories.select(&:expert?).sum(&:testing_hours)
      }
    end
  end

  def stories
    @stories ||= begin
      reports.map(&:stories).flatten.uniq
    end
  end

  def finished_stories
    @finished_stories ||= begin
      stories.select do |story|
        (params_search[:start_date]..params_search[:end_date]).include?(story.finished_at)
      end
    end
  end

  def time_based_on_difficulty
    Story.levels.keys.reduce({}) do |data, level|
      stories_by_level = finished_stories.select{|x| x.send("#{level}?")}
      requirement_hours = stories_by_level.sum(&:requirement_hours)
      design_hours = stories_by_level.sum(&:design_hours)
      coding_hours = stories_by_level.sum(&:coding_hours)
      testing_hours = stories_by_level.sum(&:testing_hours)
      bug_fixing_hours = stories_by_level.sum(&:bug_fixing_hours)
      release_hours = stories_by_level.sum(&:release_hours)
      cross_support_hours = stories_by_level.sum(&:cross_support_hours)
      total_hours = stories_by_level.sum(&:total_spent_hours)

      requirement_size = stories_by_level.reject{|x| x.requirement_hours.zero?}.size
      design_size = stories_by_level.reject{|x| x.design_hours.zero?}.size
      coding_size = stories_by_level.reject{|x| x.coding_hours.zero?}.size
      testing_size = stories_by_level.reject{|x| x.testing_hours.zero?}.size
      bug_fixing_size = stories_by_level.reject{|x| x.bug_fixing_hours.zero?}.size
      release_size = stories_by_level.reject{|x| x.release_hours.zero?}.size
      cross_support_size = stories_by_level.reject{|x| x.cross_support_hours.zero?}.size

      data.merge({
        level => {
          requirement: requirement_size.zero? ? 0 : (requirement_hours/requirement_size).round(4),
          design: design_size.zero? ? 0 : (design_hours/design_size).round(4),
          coding: coding_size.zero? ? 0 : (coding_hours/coding_size).round(4),
          testing: testing_size.zero? ? 0 : (testing_hours/testing_size).round(4),
          bug_fixing: bug_fixing_size.zero? ? 0 : (bug_fixing_hours/bug_fixing_size).round(4),
          release: release_size.zero? ? 0 : (release_hours/release_size).round(4),
          cross_support: cross_support_size.zero? ? 0 : (cross_support_hours/cross_support_size).round(4),
          total: stories_by_level.size.zero? ? 0 : (total_hours/stories_by_level.size).round(4)
        }
      })
    end
  end

  private

  def reports
    @reports ||= begin
      collections = model_report.where(public: true)
        .where("team_reports.start_date >= ? AND team_reports.start_date <= ?",
          params_search[:start_date].try(report_mapping_start_date_method[params_search[:report_type]]),
          params_search[:end_date].try(report_mapping_start_date_method[params_search[:report_type]])
      ).where(user_id: params_search[:user_id])
      .includes(:tasks, :stories)
    end
  end

  def model_report
    @model_report ||= begin
      if params_search[:user_id]
        "user_#{params_search[:report_type]}"
      else
        params_search[:report_type].to_s
      end.classify.constantize
    end
  end

  def report_mapping_start_date_method
    @report_mapping_start_date_method ||= begin
      {
        "daily_report" => :to_date,
        "weekly_report" => :beginning_of_week,
        "monthly_report" => :beginning_of_month,
        "quarter_report" => :beginning_of_quarter
      }
    end
  end
end
