# coding: utf-8
class PushWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :messages
  
  def perform(msg, receipts = [], extras_data = {})
    puts 'starting...'
    PushService.push(msg, receipts, extras_data)
  end
  
end