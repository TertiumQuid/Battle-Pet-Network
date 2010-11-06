class Facebook::SignsController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :ensure_has_pet
  
  def create
    params[:sign] ||= {}
    sign_type = (params[:sign_type] ||= params[:sign][:sign_type])
    @sign = current_user_pet.signings.build(:recipient_id => params[:pet_id], :sign_type => sign_type)
    
    if @sign.save
      flash[:notice] = "You #{@sign.verb} #{@sign.recipient.name}. #{@sign.effects}"
    else
      flash[:error] = "Couldn't #{@sign.sign_type}! :("
      flash[:error_message] = @sign.errors.full_messages.join(', ')
    end
    redirect_facebook_back
  end
end