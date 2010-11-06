class Facebook::PetsController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :except => [:index, :show, :new]
  before_filter :ensure_has_pet, :only => [:combat,:profile,:update,:destroy]
  before_filter :ensure_no_pet, :only => [:new,:create]  
  
  def index
    scope = Pet.include_user.active
    scope = scope.searching(params[:search]) if params[:search]
    @pets = scope.paginate :page => params[:page]
  end
  
  def combat
    @pet = current_user_pet
    @strategies = current_user_pet.strategies.include_maneuvers.active
    @gear = @pet.belongings.battle_ready
    @levels = @pet.breed.levels
    @challenges = current_user_pet.challenges.issued.defending
    @resolved = current_user_pet.challenges.resolved.all
  end
  
  def profile
    @pet = current_user_pet
    @messages = current_user_pet.inbox(:limit => 5)
    @signs = @pet.signs
    @challenges = current_user_pet.challenges.issued.defending
    @items = current_user_pet.belongings.holding.all(:limit => 9)
    @tames = current_user_pet.tames.kenneled.all
    @shop = @pet.shop(:include => :inventories) if has_shop?
  end
  
  def show
    @pet = Pet.find_by_id(params[:id]) || Pet.new
  end
  
  def new
    @pet = Pet.new
    @breeds = Breed.all
  end
  
  def create
    @pet = current_user.pets.new(params[:pet])
    
    if @pet.save
      flash[:success] = "Pet befriended!"
      facebook_redirect_to profile_facebook_pet_path
    else
      flash[:error] = "Couldn't befriend pet! :("
      flash[:error_message] = @pet.errors.full_messages.join(', ')
      @breeds = Breed.all
      @breed = Breed.find_by_id(@pet.breed_id)
      render :action => :new
    end
  end

  def update
    if params[:pet]
      action = params[:pet][:favorite_action_id]
      occupation = params[:pet][:occupation_id]
      success = true
    
      if action
        update_favorite_action(action)
      elsif occupation
        update_occupation(occupation)
      else
        flash[:notice] = "Nothing to update"
      end
    end
    
    redirect_facebook_back
  end
  
  def retire
    current_user_pet.retire!
    flash[:notice] = "All good things must come to an end. You've retired your dear pet."
    facebook_redirect_to new_facebook_pet_path
  end
  
protected
  
  def update_favorite_action(action_id)
    if current_user_pet.update_favorite_action!(action_id)
      flash[:notice] = "Your favorite action is now to #{current_user_pet.favorite_action.name}"
    else
      flash[:error] = "Couldn't update favorite action :("
      flash[:error_message] = current_user_pet.errors.full_messages.join(', ')
    end
  end
  
  def update_occupation(occupation_id)
    if current_user_pet.update_occupation!(occupation_id)
      flash[:notice] = "Your pet is now #{current_user_pet.occupation.name}"
    else
      flash[:error] = "Couldn't update occupation :("
      flash[:error_message] = current_user_pet.errors.full_messages.join(', ')
    end
  end
  
  def ensure_no_pet
    if has_pet?
      flash[:alert] = "You cannot befriend a new pet while you already one; you must first retire your current pet"
      redirect_facebook_back
    end
  end
end
