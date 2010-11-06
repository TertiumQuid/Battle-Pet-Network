module Facebook::ForumsHelper
  def topic_icon(post)
    src = if post && post.forum_topic.locked && post.forum_topic.sticky
      "ui/forums/locked-sticky-topic.png"
    elsif post && post.forum_topic.locked 
      "ui/forums/locked-topic.png"
    elsif post && post.forum_topic.sticky
      "ui/forums/sticky-topic.png"
    elsif registered? && post.created_at > current_user.last_login_at  
      "ui/forums/new-topic.png"
    else
      "ui/forums/topic.png"
    end
    facebook_image_tag src
  end
end