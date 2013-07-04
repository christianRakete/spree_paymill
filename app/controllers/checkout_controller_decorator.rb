Spree::CheckoutController.class_eval do
  def update
    if @order.update_attributes(object_params)
      fire_event('spree.checkout.update')
      return if after_update_attributes
      
      if params[:paymillToken].present?
        puts "&&&&&&&&&&&&&&&&&&&&&&&&&"
        puts @order.payments.inspect
        @order.payments.last.response_code = params[:paymillToken]
        @order.payments.last.save!
      end

      unless @order.next
        flash[:error] = Spree.t(:payment_processing_failed)
        redirect_to checkout_state_path(@order.state) and return
      end

      if @order.completed?
        session[:order_id] = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      render :edit
    end
  end
end