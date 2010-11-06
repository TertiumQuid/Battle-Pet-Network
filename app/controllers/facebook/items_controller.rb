class Facebook::ItemsController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :ensure_has_pet, :only => [:purchase]
  
  def index
  end
  
  def store
    @items = Item.marketable.type_is(params[:id]).paginate(:order => 'items.stock DESC', :page => params[:page])
    @shops = Shop.specialists(params[:id])
  end
  
  def purchase
    @item = Item.find(params[:id])
    @purchase = @item.purchase_for!(current_user_pet)
    @purchase_errors = @purchase.errors.on_base
        
    if @purchase_errors.blank?
      flash[:success] = "You bought the #{@item.name}!"
    else    
      flash[:error] = "Couldn't purchase item: #{@purchase_errors}"
      flash[:error_message] = @item.errors.full_messages.join(', ')
    end
    redirect_facebook_back
  end
  
  def premium
    @items = Item.premium.kibble.all
    @payment_order = PaymentOrder.new
  end
end