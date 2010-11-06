class Facebook::ForumPostsController < Facebook::FacebookController
  def edit
    @forum = Forum.find_for_user(current_user,params[:forum_id])
    @topic = @forum.topics.find(params[:forum_topic_id])
    @post = @topic.posts.find(params[:id])
  end
  
  def update
    @forum = Forum.find_for_user(current_user,params[:forum_id])
    @topic = @forum.topics.find(params[:forum_topic_id])
    @post = @topic.posts.find(params[:id])
    
    if @post.can_edit?(current_user) && @post.update_attributes(params[:forum_post])
      flash[:notice] = "Post updated."
      facebook_redirect_to facebook_forum_forum_topic_path(@forum,@topic)
    else
      flash[:error] = "Couldn't update post! :("
      flash[:error_message] = @post.errors.full_messages.join(', ')
      render :action => :edit
    end
  end
  
  def create
    @forum = Forum.find_for_user(current_user,params[:forum_id])
    @topic = @forum.topics.find(params[:forum_topic_id])
    @post = @topic.posts.new(params[:forum_post])
    @post.user = current_user
    
    if @post.save
      flash[:success] = "Post created"
    else
      flash[:error] = "Couldn't create post! :("
      flash[:error_message] = @post.errors.full_messages.join(', ')
    end  
    facebook_redirect_to facebook_forum_forum_topic_path(@forum,@topic)
  end
end