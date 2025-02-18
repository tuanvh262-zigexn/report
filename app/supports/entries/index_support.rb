class Entries::IndexSupport
  attr_accessor :params_q

  def initialize params_q
    @params_q = params_q
  end

  def params_search
    @params_search ||= params_q || { user_ids: User.actived.pluck(:id).map(&:to_s) }
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
    (Date.current - 2.week).beginning_of_week..(Date.current + 1.months)
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
      Story.where(status: [:init, :in_progress, :resolved, :code_review, :testing, :verified])
        .where(id: tasks.pluck(:story_id).uniq)
    end
  end

  def tasks
    @tasks ||= begin
      SubTask.joins(:story)
        .merge(
          Story.where(status: [:init, :in_progress, :resolved, :code_review, :testing, :verified])
      ).where(owner_id: params_search[:user_ids]).includes(:owner).order(:start_date)
    end
  end
end
