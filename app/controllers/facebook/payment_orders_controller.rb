class Facebook::PaymentOrdersController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user
  
  def create
    @payment_order = current_user.payment_orders.new(params[:payment_order])
    
    if @payment_order.save
      res = EXPRESS_GATEWAY.setup_purchase( @payment_order.price_in_cents,
        :ip                => request.remote_ip,
        :order_id          => @payment_order.id,
        :description       => "#{@payment_order.item.name}: $#{@payment_order.price_in_cents}",
        :no_shipping       => true,
        :return_url        => new_facebook_payment_order_payment_order_transaction_path(@payment_order),
        :cancel_return_url => premium_facebook_items_path
      )
      redirect_to EXPRESS_GATEWAY.redirect_url_for(res.token)    
    else
      flash[:error] = "Could not start purchase."
      flash[:error_message] = @payment_order.errors.full_messages.join(', ')
      redirect_facebook_back
    end
  end
end