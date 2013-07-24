Spree::CheckoutController.class_eval do
  
  def update
    if @order.update_attributes(object_params)
      fire_event('spree.checkout.update')
      
      if params[:paymillToken].present?
        @order.payment.response_code = params[:paymillToken]
        @order.payment.save!
      end

      unless @order.next
        flash[:error] = @order.errors[:base].join("\n")
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