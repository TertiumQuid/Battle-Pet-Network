class Facebook::StrategiesController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :ensure_has_pet
  
  def destroy
    @strategy = current_user_pet.strategies.find(params[:id])
    @strategy.update_attribute(:status, 'used')
    flash[:notice] = "Strategy forgotten"
    redirect_facebook_back
  end
end