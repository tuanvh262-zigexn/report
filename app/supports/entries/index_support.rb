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
    @data_ranges ||= list_date.each_with_object({}) do |date, data|
      data[date.strftime("%Y-%m")] = (data[date.strftime("%Y-%m")] || []).push(date)
    end
  end

  def list_date
    @list_date ||= min_date..max_date
  end

  def min_date
    @min_date ||= ((stories.map(&:start_date).compact.min || Date.current) - 2.week).beginning_of_week
  end

  def max_date
    @max_date ||= ((stories.map(&:due_date).compact.max || Date.current) + 2.week).end_of_week
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
        .where(id: tasks.pluck(:story_id).uniq).includes(:user)
    end
  end

  def parent_tasks_with_story_id
    @parent_task ||= begin
      tasks.each_with_object({}) do |task, data|
        story_id = task.story_id

        data[story_id] = if data[story_id]
          data[story_id].any?{|x| x[:id] == task.parent.id} ? data[story_id] : data[story_id].push(task.parent)
        else
          [task.parent]
        end
      end
    end
  end

  def tasks_with_parent_id
    @tasks_with_parent_id ||= begin
      tasks.each_with_object({}) do |task, data|
        parent_id = task.parent_task_id

        data[parent_id] = data[parent_id] ? data[parent_id].push(task) : [task]
      end
    end
  end

  def tasks
    @tasks ||= begin
      query = SubTask.without_parent_tasks.joins(:story)
        .merge(
          Story.where(status: [:init, :in_progress, :resolved, :code_review, :testing, :verified, :feedback, :ready_for_test, :jp_side])
      ).where(owner_id: params_search[:user_ids], status: task_statuses)
      .where(start_date: Date.current-1.month..Date.current+1.month)

      query.includes(:owner, parent: :owner).order(start_date: :asc)
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
