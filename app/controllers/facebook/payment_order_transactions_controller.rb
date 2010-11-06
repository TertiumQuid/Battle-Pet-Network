class Facebook::PaymentOrderTransactionsController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user
  
  def new
    @po = PaymentOrder.find_or_initialize_by_user_token(current_user,params[:token])
    @po.ip_address = request.remote_ip
    
    if @po.save_and_purchase
      flash[:success] = "Thanks! You purchased a #{@po.item.name}."
    else
      flash[:error] = "There was a problem with your order."
      flash[:error_message] = @po.errors.full_messages.join(', ')
    end
  end
end