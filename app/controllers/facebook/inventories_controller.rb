class Facebook::InventoriesController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :ensure_has_pet
  
  def create
    @shop = current_user_pet.shop
    @inventory = @shop.inventories.build(params[:inventory])
    
    if @inventory.save
      flash[:notice] = "Item added to your inventory"
    else
      flash[:error] = "Couldn't add item to inventory! :("
      flash[:error_message] = @inventory.errors.full_messages.join(", ")
    end
    redirect_facebook_back
  end
  
  def update
    @shop = current_user_pet.shop
    @inventory = @shop.inventories.find(params[:id])
        
    if @inventory.update_attributes(params[:inventory])
      flash[:notice] = "Inventory updated"
    else    
      flash[:error] = "Couldn't update inventory. :(" 
      flash[:error_message] = @inventory.errors.full_messages.join(", ")
    end
    redirect_facebook_back
  end
  
  def purchase
    @shop = Shop.find(params[:shop_id])
    @inventory = @shop.inventories.find(params[:id])
    
    @purchase = @inventory.purchase_for!(current_user_pet)
    @purchase_errors = @purchase.errors.on_base

    if @purchase_errors.blank?
      flash[:success] = "You bought the #{@inventory.item.name}!"
    else    
      flash[:error] = "Couldn't purchase item :("
      flash[:error_message] = @inventory.errors.full_messages.join(", ")
    end
    redirect_facebook_back
  end
  
  def destroy
    @shop = current_user_pet.shop
    @inventory = @shop.inventories.find(params[:id])
    @inventory.unstock!
    flash[:notice] = "Item added to your inventory"
    redirect_facebook_back
  end
end
