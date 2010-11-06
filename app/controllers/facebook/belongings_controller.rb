class Facebook::BelongingsController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :ensure_has_pet
  
  def index
    @items = current_user_pet.belongings.paginate :page => params[:page]
    @gear = current_user_pet.belongings.battle_ready   
  end
  
  def update
    @belonging = current_user_pet.belongings.find(params[:id])
        
    if @belonging.use_item
      flash[:success] = "Used #{@belonging.item.name}"
    else    
      flash[:error] = "Couldn't use #{@belonging.item.name}: "
      flash[:error_message] = "#{@belonging.errors.full_messages.join(', ')}"
    end
    redirect_facebook_back
  end
end