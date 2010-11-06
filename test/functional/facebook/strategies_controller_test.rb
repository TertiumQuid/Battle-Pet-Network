require 'test_helper'

class Facebook::StrategiesControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @strategy = strategies(:siamese_strategy)
    @pet = @strategy.combatant
    @user = @pet.user
  end

  def test_destroy
    mock_user_facebooking(@user.facebook_id)
    assert @strategy.update_attribute(:status, 'active')
    facebook_delete :destroy, :id => @strategy.id, :fb_sig_user => @user.facebook_id
    assert_equal 'used', @strategy.reload.status
    assert flash[:notice]
  end
end