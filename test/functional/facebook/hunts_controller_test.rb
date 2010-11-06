require 'test_helper'

class Facebook::HuntsControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @user = users(:two)
    @pet = @user.pet
    @sentient = sentients(:leper_rat)
    @new_strategy_params = {:maneuvers_attributes => { "0" => {:rank => 1, :action_id => actions(:scratch).id}}}
    @params = {:sentient_id => @sentient.id, :hunters_attributes => {"0" => {:pet_id => @pet.id, :strategy_attributes => @new_strategy_params}} }
  end
  
  def test_show
    @pet = pets(:persian)
    @user = @pet.user
    mock_user_facebooking(@user.facebook_id)
    facebook_get :show, :fb_sig_user => @user.facebook_id, :id => hunts(:omega_rat_hunt).id
    assert_response :success
    assert_template 'show'
    assert !assigns(:hunt).blank?
    assert !assigns(:hunts).blank?
    assert_tag :tag => "ul", :attributes => {:class => 'hunts'}, :descendant => {
      :tag => "li", :attributes => { :class => "hunt" }
    }
    assert_tag :tag => "ul", :attributes => {:class => 'logs'}, :descendant => {
      :tag => "li", :attributes => { :class => "log" }
    }
  end

  def test_get_new
    mock_user_facebooking(@user.facebook_id)
    facebook_get :new, :fb_sig_user => @user.facebook_id, :sentient_id => @sentient.id
    assert_response :success
    assert_template 'new'
    assert !assigns(:sentient).blank?
    assert !assigns(:hunt).blank?
    assert !assigns(:hunt).hunters.blank?
    assert !assigns(:hunt).hunter.strategy.blank?
    assert assigns(:hunt).hunters.map(&:pet_id).include?(@pet.id)
    assert_tag :tag => "form", :descendant => { 
      :tag => "table", :attributes => { :class => "comparison-table" },
      :tag => "ul", :attributes => { :class => "tactics" },
      :tag => "li", :attributes => { :class => "tactic" },
      :tag => "input", :attributes => { :type => "submit" }
    }
  end

  def test_create
    mock_user_facebooking(@user.facebook_id)   
    assert_difference ['Hunt.count','Hunter.count','Strategy.count','ActivityStream.count'], +1 do
      facebook_post :create, :sentient_id => @sentient.id, :hunt => @params, :fb_sig_user => @user.facebook_id
      assert_response :success
      assert !assigns(:hunt).blank?
      assert !assigns(:hunt).hunters.blank?
      assert !assigns(:hunt).hunter.strategy.blank?
      assert !assigns(:hunt).hunter.strategy.maneuvers.blank?
      assert !assigns(:hunt).logs.blank?
      h = Hunt.find(assigns(:hunt).id)
      h.logs[:outcome] = "test"
      h.save!
      assert assigns(:hunt).hunters.map(&:pet_id).include?(@pet.id)
    end    
    assert flash[:success] || flash[:notice]
  end

  def test_fail_create
    mock_combat
    mock_user_facebooking(@user.facebook_id)   
    assert_no_difference ['Hunt.count','Hunter.count','Strategy.count','ActivityStream.count'] do
      @params = {:hunters_attributes => {"0" => {"strategy_id"=>""} }}
      facebook_post :create, :sentient_id => @sentient.id, :fb_sig_user => @user.facebook_id, :hunt => @params
      assert_response :success
      assert !assigns(:hunt).blank?
      assert !assigns(:hunt).hunters.blank?
      assert !assigns(:hunt).hunter.strategy.blank?
    end    
    assert flash[:error]
    assert flash[:error_message]
  end
end