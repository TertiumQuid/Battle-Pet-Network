class Facebook::HuntsController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :ensure_has_pet
  before_filter :initialize_hunt, :only => [:new,:create]
  
  def new
    @sentient = Sentient.find(params[:sentient_id])
    @hunt = @sentient.hunts.build(@defaults)
  end
  
  def create
    @sentient = Sentient.find(params[:sentient_id])
    @hunt = @sentient.hunts.build(params[:hunt] )
    
    # ensure current_user_pet is combatant
    unless @hunt.hunters.blank?
      @hunt.hunter.pet = current_user_pet 
      strategy_sent = !@hunt.hunter.strategy.blank? || !@hunt.hunter.strategy_id.blank?
      @hunt.hunter.strategy.combatant = current_user_pet if strategy_sent
    end

    if @hunt.save
      flaash_key = @hunt.hunters.first.outcome == "won" ? :success : :notice
      flash[flaash_key] = "The hunt for the #{@sentient.name} was #{@hunt.hunters.first.outcome}"
      facebook_redirect_to facebook_hunt_path(@hunt)
    else
      flash[:error] = "Couldn't start hunt. :("
      flash[:error_message] = @hunt.errors.full_messages.join(", ")
      
      @hunt = @sentient.hunts.build(@defaults.merge(params[:hunt]) )
      render :action => :new
    end
  end
  
  def show
    @hunt = current_user_pet.hunters.find_by_hunt_id(params[:id])
    @hunts = current_user_pet.hunters.all(:limit => 12).map(&:hunt)
  end
  
  def initialize_hunt
    params[:hunt] ||= {}
    @defaults = {:hunters_attributes => 
                {"0" => { 
                  :pet_id => current_user_pet.id, 
                  :strategy_attributes => {:combatant_id => current_user_pet.id, :combatant_type => 'Pet'} 
                }}}    
  end
end