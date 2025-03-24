class Entries::IndexSupport
  attr_accessor :params_q

  def initialize params_q
    @params_q = params_q || {}
  end

  def params_search
    @params_search ||= begin
      if params_q.dig(:user_ids)
        params_q
      else
        params_q.merge({ user_ids: User.actived.pluck(:id).map(&:to_s) })
      end
    end
  end

  def adsdsd
    @adsdsd ||= begin
      tasks.each_with_object({}) do |task, data|
        next unless task.start_date && task.due_date
        (task.start_date..task.due_date).each do |date|
          date_key = date.strftime("%Y-%m-%d")

          data[date_key] = data[date_key] ? data[date_key].push(task.id) : [task.id]
        end
      end
    end
  end

  def data_ranges
    date_ranges = adsdsd.keys
    list_date.each_with_object({}) do |date, data|
      data[date.strftime("%Y-%m")] = (data[date.strftime("%Y-%m")] || []).push(date)
    end
  end

  def list_date
    date_ranges = adsdsd.keys
    (Date.current - 2.week).beginning_of_week..(Date.current + 2.week).end_of_week
  end

  def class_name task, date
    return :holiday if date.saturday? || date.sunday?

    if (adsdsd[date.strftime("%Y-%m-%d")] || []).include? task.id
      if task.closed?
        return :done
      elsif date < Date.current
        return :in_progress
      else
        return :activity
      end
    end

    :today if date.today?
  end

  def stories
    @stories ||= begin
      Story.where(status: [:init, :in_progress, :resolved, :code_review, :testing, :verified, :feedback, :ready_for_test, :jp_side])
        .where(id: tasks.pluck(:story_id).uniq).includes(:time_crowd_task)
    end
  end

  def tasks
    @tasks ||= begin
      query = SubTask.joins(:story)
        .merge(
          Story.where(status: [:init, :in_progress, :resolved, :code_review, :testing, :verified, :feedback, :ready_for_test, :jp_side)
            .where.not(issue_id: Settings.redmine.issue_id_valid)
      ).where(owner_id: params_search[:user_ids], status: task_statuses)

      if params_search[:include_status_done]
        query = query.or(
          SubTask.where("(((sub_tasks.status = 11 AND sub_tasks.redmine_created_at > ?) OR sub_tasks.status != 11) AND stories.issue_id IN (67210, 70517))", Date.current - 2.weeks)
            .where(owner_id: params_search[:user_ids])
        )
      else
        query = query.or(
          SubTask.where("(sub_tasks.status != 11 AND stories.issue_id IN (67210, 70517))")
            .where(owner_id: params_search[:user_ids])
        )
      end

      query.includes(:owner).order(start_date: :asc)
    end
  end

  private

  def task_statuses
    if params_search[:include_status_done]
      SubTask.statuses.keys
    else
      SubTask.statuses.keys - ["closed"]
    end
  end
end
