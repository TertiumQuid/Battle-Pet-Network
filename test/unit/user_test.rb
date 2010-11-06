require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    mock_user_facebooking
    @user = users(:one)
  end
  
  def test_initializes
    user = User.new
    assert_equal 'member', user.role
  end
  
  def test_should_update_from_facebook_session
    attributes_to_update = [:username,:email,:gender,:locale]
    @user = User.create(:facebook_id => "3145")
    @user.update_from_facebook_session(@facebook_session_mock)
    assert @user.save
    
    attributes_to_update.each do |a|
      assert_not_nil @user.send(a)
    end
  end
  
  def test_should_update_from_facebook_session_key
    keys = ["9402cdbb42a1fb18adf", @user.facebook_session_key]
    keys.each do |session_key|
      attributes_to_update = {:facebook_session_key => @user.facebook_session_key, 
                              :last_login_at => @user.last_login_at, 
                              :last_request_at => @user.last_request_at, 
                              :current_login_at => @user.current_login_at}
      @user.update_from_facebook_session_key(session_key)
      assert @user.save
    
      attributes_to_update.each_pair do |key, value|
        if session_key != attributes_to_update[:facebook_session_key]
          assert_not_equal @user.send(key), value
        else
          assert_equal @user.send(key), value
        end
      end
    end
  end
  
  def test_normalized_name
    username = User.new(:username => 'un')
    assert_equal 'un', username.normalized_name
    fullname = User.new(:first_name => 'first', :last_name => 'last')
    assert_equal 'first last', fullname.normalized_name
    mysterio = User.new
    assert_equal 'mysterio', mysterio.normalized_name
  end
  
  def test_staff
    user = User.new
    User::ROLES.each do |r|
      user.role = r 
      assert (r == 'member' ? !user.staff? : user.staff?)
    end
  end
end