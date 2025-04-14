class Timecrowd::CreateCategoryWorker
  include Sidekiq::Worker

  def perform data
    category = JSON.parse(data)

    return if TimecrowdCategory.exists?(timecrowd_id: category["timecrowd_id"])

    TimecrowdCategory.create!(category)
  end
end
