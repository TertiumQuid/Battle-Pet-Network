class Facebook::ForumTopicsController < Facebook::FacebookController
  before_filter :ensure_application_is_installed_by_facebook_user, :except => [:show]
  
  def new
    @forum = Forum.find_for_user(current_user,params[:forum_id])
    @topic = @forum.topics.new
    @post = @topic.posts.build
  end
  
  def create
    @forum = Forum.find_for_user(current_user,params[:forum_id])
    @topic = @forum.topics.new(params[:forum_topic])
    @topic.user = current_user
    @topic.posts.first.user = @topic.user unless @topic.posts.blank?
    
    if @topic.save
      flash[:success] = "Topic created"
      facebook_redirect_to facebook_forum_forum_topic_path(@forum,@topic)
    else
      flash[:error] = "Couldn't create topic! :("
      flash[:error_message] = @topic.errors.full_messages.join(', ')
      render :action => :new
    end    
  end
  
  def show
    @forum = Forum.find_for_user(current_user,params[:forum_id])
    @topic = @forum.topics.find(params[:id])
    @posts = @topic.posts.paginate :page => params[:page]
    @post = @topic.posts.new
    
    @topic.touch_views!
  end
end