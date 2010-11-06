class ForumTopic < ActiveRecord::Base
  belongs_to :forum, :counter_cache => true
  belongs_to :user
  belongs_to :last_post, :class_name => "ForumPost"
  has_many :posts, :class_name => "ForumPost", 
                   :foreign_key => "forum_topic_id", 
                   :order => "created_at ASC"
  
  validates_presence_of :forum_id, :user_id, :title
  validates_length_of :title, :in => 3..128
  
  accepts_nested_attributes_for :posts, :allow_destroy => false  
  
  def touch_views!
    update_attribute(:views_count, views_count + 1)
  end
    
  def editable_by?(user)
    user && (user.id == user_id)
  end  
  
  def sticky?
    return self.sticky
  end  
  
  def locked?
    return self.locked
  end
end