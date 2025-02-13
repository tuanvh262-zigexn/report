class UserDailyReport < TeamReport
  belongs_to :user

  def time_period
    :to_date
  end
end
