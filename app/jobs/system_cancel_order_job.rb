class SystemCancelOrderJob < ActiveJob::Base
  queue_as :scheduled_jobs

  def perform(order_id)
    @order = Order.find_by(id: order_id)
    if @order and @order.can_cancel?
      @order.cancel
      Message.create!(content: '系统取消了您的订单', to: @order.item.user.id)
    end
  end
end
