class Facebook::ForumsController < Facebook::FacebookController
  def index
    @forums = Forum.find_for_user(current_user)
  end
  
  def show
    @forum = Forum.find_for_user(current_user,params[:id])
    @topics = @forum.topics.paginate :page => params[:page]
  end
end