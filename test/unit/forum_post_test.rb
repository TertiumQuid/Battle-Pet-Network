require 'test_helper'

class ForumPostTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @topic = forum_topics(:discussion_rules)
    @post = forum_posts(:discussion_rules_1)
  end
  
  def test_touch_parents
    post = @topic.posts.build(:body => 'test', :user => @user)
    assert_difference ['@topic.reload.forum_posts_count','@topic.reload.forum.forum_posts_count'], +1 do
      assert post.save
    end
    assert_equal post, @topic.reload.last_post
    assert_equal post, @topic.forum.last_post
  end
  
  def test_can_edit
    assert @post.can_edit?(@user)
    assert !@post.can_edit?(@other_user)
    @other_user.update_attribute(:role, 'staff')
    assert @post.can_edit?(@other_user)
  end
end