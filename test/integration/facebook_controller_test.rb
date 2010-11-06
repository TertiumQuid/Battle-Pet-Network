require 'test_helper'

class FacebookControllerTest < ActionController::IntegrationTest
  def setup
    mock_user_facebooking
  end
  
  def get_root
    get facebook_root_path, :fb_sig => Authlogic::Random.friendly_token
  end
  
  def test_facebook_layout
    get_root
    assert_response :success
    assert_tag :tag => "fb:tabs"
    assert_tag :tag => "fb:bookmark"
  end
  
  def test_facebook_path_scrub
    get_root
    ['facebook/index','/facebook/index', 'facebook', 'facebook/index/'].each do |p|
      scrubbed = @controller.facebook_path_scrub('facebook/index')
      assert !scrubbed.include?('facebook')
      assert !scrubbed.include?('//')
    end
  end
  
  def test_store_location
    route = '/index'
    get_root
    flexmock(@controller).should_receive(:request).and_return( flexmock(:request_uri => route, :method => 'get') )
    @controller.store_location
    assert_equal "#{Facebooker.current_adapter.facebooker_config['canvas_page_name']}#{route}", session[:return_to]
  end
  
  def test_stored_location
    get_root
    assert_equal 'battlecat', @controller.stored_location
  end
end