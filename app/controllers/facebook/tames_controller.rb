class Facebook::TamesController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :ensure_has_pet

  def index
    @tames = current_user_pet.tames.kenneled.all
    @slave_count = current_user_pet.tames.enslaved.count
  end
  
  def enslave
    @tame = Tame.find(params[:"id"])
    current_user_pet.tames.kenneled.enslave(@tame.id)
    facebook_redirect_to facebook_kennel_index_path
  end
  
  def release
    @tame = Tame.find(params[:"id"])
    current_user_pet.tames.kenneled.release(@tame.id)
    facebook_redirect_to facebook_kennel_index_path    
  end
end