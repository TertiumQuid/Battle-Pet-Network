class Facebook::PacksController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :ensure_has_pet, :except => [:show, :index]
  
  def index
  end
  
  def show
    @pack = Pack.include_pack_members.find(params[:id])
  end
  
  def new
    @pack = current_user_pet.build_pack
    @standards = current_user_pet.belongings.standards
  end
  
  def create
    @pack = current_user_pet.build_pack(params[:pack])

    if @pack.save
      flash[:success] = "Today will be remembered in history as the founding of your pack!"
      facebook_redirect_to facebook_pack_path(@pack)
    else
      flash[:error] = "Couldn't found pack! :("
      flash[:error_message] = @pack.errors.full_messages.join(', ')
      @standards = current_user_pet.belongings.standards
      render :action => :new
    end    
  end
  
  def edit
    @pack = current_user_pet.pack
    @items = current_user_pet.belongings.sellable.collect(&:item)
  end
  
  def update
    @pack = current_user_pet.pack
    @pack.attributes = params[:pack] if current_user_pet.id == @pack.leader_id
    
    if @pack.disbanded?
      flash[:notice] = "Disbanded your pack and scattered the members to the 4 winds."
      facebook_redirect_to profile_facebook_pet_path(current_user_pet)
    else
      flash[:notice] = "Pack updated"
      facebook_redirect_to edit_facebook_pack_path(@pack)
    end
  end

  def invite
    @pack = current_user_pet.pack
    @pet = Pet.find_by_slug(params[:invittee]) || Pet.find_by_name(params[:invittee])
    
    message = @pack.invite_membership(current_user_pet,@pet)
    if message.new_record?
      flash[:error] = "Couldn't send invite :("
      flash[:error_message] = message.errors.full_messages.join(', ')
    else
      flash[:notice] = "Invited #{params[:invittee]} to join"
    end
    redirect_facebook_back    
  end
end