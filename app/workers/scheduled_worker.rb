class ScheduledWorker #< ActiveRecord::Base
  include Sidekiq::Worker
  sidekiq_options :queue => :scheduled_jobs
  
  def perform(order_id)
    puts "System cancel order: #{order_id}"
  end
  
end