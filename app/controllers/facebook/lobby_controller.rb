class Facebook::LobbyController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :only => [:invite]
  
  def index
    @pet_activity = ActivityStream.pet_activity
    @world_activity = ActivityStream.world_activity
    @forum_posts = ForumPost.recent
  end
  
  def about
  end
  
  def guide
  end
  
  def tos
  end
  
  def contact
  end
  
  def invite
    @exclude_ids = current_user.facebook_friend_ids
  end
end