ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'flexmock/test_unit'

class ActiveSupport::TestCase
  include ActionController::TestProcess
  
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  
  AppConfig.tweets = 0
  
  # Network / File IO Mocking
  def mock_tweets
    @tweets_xml = fixture_file_upload("files/tweets.xml",'text/xml', false)
    flexmock(Twitter::TweetsToHtml).new_instances.should_receive(:load_xml).and_return(@tweets_xml)
    flexmock(Twitter::TweetsToHtml).new_instances.should_receive(:load_from_filesystem).and_return(@tweets_xml)
    flexmock(Twitter::TweetsToHtml).new_instances.should_receive(:load_from_twitter).and_return(@tweets_xml)
  end 
    
  # A convinience wrapper for the native Rails logger
  def logger
    RAILS_DEFAULT_LOGGER
  end  
  
  def rescue_save(model)
    begin
     model.save
    rescue
    end
  end
  
  def mock_combat
    @battle_mock = flexmock(Battle)
    @hunt_mock = flexmock(Hunt)
    @battle_mock.new_instances.should_receive(:run_combat)
    @hunt_mock.new_instances.should_receive(:run_combat)
  end
  
  def mock_activity
    @activity_mock = flcokmock(ActivityStream)
    @activity_mock.new_instances.should_receive(:log!).and_return(true)
  end
  
  def mock_merchant
    @gateway_response = flexmock(:token => "1234", 
                                :success? => true, 
                                :authorization => true,
                                :message => "Success",
                                :params => {}) 
                                
    @purchase = flexmock(:token => "1234")                            
                                
    @pending_po = payment_orders(:user_two_pending_po)                            
    @token_details = flexmock(:params => {"ack" => "Success",
                                         "first_name" => "Test",
                                         "middle_name" => "T.",
                                         "last_name" => "Test",
                                         "payer" => "test@example.com",
                                         "phone" => "123-456-7890",
                                         "country" => "USA",
                                         "city" => "Boston",
                                         "total" => "2.00",
                                         "invoice_id" => @pending_po.id
       }, :payer_id => "1234")                        

    @gateway_mock = flexmock(EXPRESS_GATEWAY)
    @gateway_mock.should_receive(:details_for).and_return(@token_details)
    @gateway_mock.should_receive(:purchase).and_return(@gateway_response)
    @gateway_mock.should_receive(:setup_purchase).and_return(@purchase)
    @gateway_mock.should_receive(:redirect_url_for).and_return('')
  end

  def mock_user_facebooking(facebook_id="2147483647")
    @facebook_session_mock = flexmock(Facebooker::Session)
    @facebook_session_mock.should_receive(:secured?).and_return(true)
    @facebook_session_mock.should_receive(:session_key).and_return("key01029")
    
    @facebook_user_mock = flexmock(Facebooker::User)
    @facebook_user_mock.should_receive(:populate)
    @facebook_user_mock.should_receive(:name).and_return('mock user')
    @facebook_user_mock.should_receive(:proxied_email).and_return('mock@example.com')
    @facebook_user_mock.should_receive(:sex).and_return('male')
    @facebook_user_mock.should_receive(:locale).and_return('en')
    @facebook_user_mock.should_receive(:uid).and_return(facebook_id)
  
    @facebook_session_mock.should_receive(:user).and_return(@facebook_user_mock)
    @user_mock = flexmock(User)
    @user_mock.new_instances.should_receive(:facebook_session).with(facebook_id).and_return(@facebook_session_mock)
    
    @controller_mock = flexmock(@controller)
    @controller_mock.should_receive(:has_facebook_user?).and_return(true)
    @controller_mock.should_receive(:set_facebook_session).and_return(true)
    @controller_mock.should_receive(:facebook_session).and_return(@facebook_session_mock)
  end
end
