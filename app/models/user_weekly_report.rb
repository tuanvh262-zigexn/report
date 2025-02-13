class UserWeeklyReport < TeamReport
  belongs_to :user

  def time_period
    :end_of_week
  end
end
