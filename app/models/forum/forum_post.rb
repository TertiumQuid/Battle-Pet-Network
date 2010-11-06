class ForumPost < ActiveRecord::Base
  belongs_to :forum_topic, :counter_cache => true
  belongs_to :user

  validates_presence_of :body
  validates_presence_of :user_id
  
  after_create :touch_parents
  
  named_scope :recent, :limit => 5, :order => 'forum_posts.created_at DESC', :include => [:forum_topic,:user]
  
  def touch_parents
    forum_topic.update_attribute(:last_post_id, self.id)
    forum_topic.forum.update_attribute(:last_post_id, self.id)
    forum_topic.forum.update_attribute(:forum_posts_count, forum_topic.forum.forum_posts_count + 1)
  end
  
  def can_edit?(u)
    u && (u.id == user_id || u.staff?)
  end
end