require 'sidekiq'
require 'sidekiq-scheduler'

redis_url = "redis://#{ENV['REDIS_URL']}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.expand_path('../../sidekiq_scheduler.yml', __FILE__))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
