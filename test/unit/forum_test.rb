require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  def setup
    @private = forums(:staff)
    @forum = forums(:discussion)
    @user = users(:one)
  end
  
  def test_find_all_for_member
    forums = Forum.find_for_user(@user)
    assert !forums.include?(@private)
  end
  
  def test_find_all_for_staff
    @user.update_attribute(:role,'staff')
    forums = Forum.find_for_user(@user)
    assert forums.include?(@private)
  end

  def test_find_for_member
    assert Forum.find_for_user(@user,@private.id).blank?
    assert !Forum.find_for_user(@user,@forum.id).blank?
  end

  def test_find_for_staff
    @user.update_attribute(:role,'staff')
    assert !Forum.find_for_user(@user,@private.id).blank?
  end
end