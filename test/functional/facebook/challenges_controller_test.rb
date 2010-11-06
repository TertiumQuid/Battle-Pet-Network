require 'test_helper'

class Facebook::ChallengesControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @attacker = pets(:siamese)
    @defender = pets(:persian)
    @user = @attacker.user
    @params = {:attacker_strategy_attributes => {
                :maneuvers_attributes => { "0" => {:action_id => actions(:scratch).id}} 
              }}
  end
  
  def test_index
    pet = pets(:persian)
    user = pet.user
    mock_user_facebooking(user.facebook_id)
    facebook_get :index, :fb_sig_user => user.facebook_id
    assert_template 'index'
    assert !assigns(:challenges).blank?
    assert !assigns(:issued).blank?
    assert !assigns(:resolved).blank?
    assert !assigns(:open).blank?
    assert_tag :tag => "ul", :attributes => { :id => 'issued-challenges'}, :descendant => { :tag => "a" }
    assert_tag :tag => "table", :attributes => {:class => 'challenge'}, :descendant => { :tag => "span", :attributes => { :class => "right button" } }
    assert_tag :tag => "table", :attributes => {:class => 'challenge'}, :descendant => { :tag => "span", :attributes => { :class => "left button" } }
    assert_tag :tag => "ul", :attributes => { :id => 'open-challenges' }
    assert_tag :tag => "ul", :attributes => { :id => 'open-challenges' }
  end
  
  def test_show
    mock_user_facebooking(@user.facebook_id)
    facebook_get :show, :fb_sig_user => @user.facebook_id, :id => challenges(:siamese_burmese_resolved).id
    assert_response :success
    assert_template 'show'
    assert !assigns(:challenge).blank?
    assert !assigns(:pet).blank?
    assert !assigns(:opponent).blank?
    assert_not_equal assigns(:opponent), @user.pet
    assert !assigns(:history).blank?
    assert_tag :tag => "ul", :attributes => { :class => 'battle-records'}, :descendant => {
      :tag => "li", :attributes => { :class => "battle" }
    }
  end
  
  def test_new
    mock_user_facebooking(@user.facebook_id)
    facebook_get :new, :fb_sig_user => @user.facebook_id, :pet_id => @defender.id
    assert_response :success
    assert_template 'new'
    assert !assigns(:challenge).blank?
    assert !assigns(:pet).blank?
    assert_tag :tag => "form", :attributes => { :action => "/pets/#{@defender.id}/challenges", :method => 'post' }
    assert_tag :tag => "form", :descendant => { :tag => "table", :attributes => { :class => "comparison-table" }}
    assert_tag :tag => "form", :descendant => { :tag => "td", :attributes => { :class => "battle-gear" }}
    assert_tag :tag => "form", :descendant => {:tag=>"input",:attributes=>{:type=>"checkbox",:name=>"attacker_strategy_attributes[status]"} }
    assert_tag :tag => "form", :descendant => { :tag => "input", :attributes => { :type => "submit" }}
  end
  
  def test_open
    mock_user_facebooking(@user.facebook_id)
    facebook_get :open, :fb_sig_user => @user.facebook_id
    assert_response :success
    assert_template 'open'
    assert !assigns(:challenge).blank?
    assert !assigns(:pet).blank?
    assert !assigns(:gear).blank?
    assert_tag :tag => "form", :descendant => {
      :tag => "input", :attributes => { :type => "submit" }
    }
    assert_tag :tag => "form", :descendant => {:tag=>"input",:attributes=>{:type=>"checkbox",:name=>"attacker_strategy_attributes[status]"} }
  end

  def test_edit_open
    mock_user_facebooking(@user.facebook_id)
    facebook_get :edit, :fb_sig_user => @user.facebook_id, :id => challenges(:burmese_open).id
    assert_response :success
    assert_template 'edit'
    assert !assigns(:challenge).blank?
    assert !assigns(:challenge).defender.blank?
  end
  
  def test_create_1v1
    Challenge.destroy_all
    mock_user_facebooking(@user.facebook_id)   
    assert_difference ['Challenge.count','Strategy.count'], +1 do
      facebook_post :create, :fb_sig_user => @user.facebook_id, :pet_id => @defender.id, :challenge => @params
      assert_response :success
      assert !assigns(:challenge).blank?
      assert !assigns(:pet).blank?
    end    
    assert flash[:notice]
  end
  
  def test_create_by_saved_strategy
    Challenge.destroy_all
    strategy = @attacker.strategies.active.first
    params = {:attacker_strategy_id => strategy.id}
    mock_user_facebooking(@user.facebook_id)   
    assert_no_difference ['Strategy.count'] do
      assert_difference ['Challenge.count'], +1 do
        facebook_post :create, :fb_sig_user => @user.facebook_id, :pet_id => @defender.id, :challenge => params
        assert_response :success
        assert !assigns(:challenge).blank?
      end  
    end
    assert_equal assigns(:challenge).attacker_strategy_id, strategy.id
  end
  
  def test_fail_create
    Challenge.destroy_all
    assert_no_difference ['Challenge.count','Strategy.count'] do
      @params = {}
      facebook_post :create, :fb_sig_user => @user.facebook_id, :pet_id => @defender.id, :challenge => @params
      assert_response :success
      assert !assigns(:challenge).blank?
      assert !assigns(:pet).blank?
    end    
    assert flash[:error]
    assert flash[:error_message]
  end

  def test_fail_create_1v0
    Challenge.destroy_all
    assert_no_difference ['Challenge.count','Strategy.count'] do
      @params = {}
      facebook_post :create, :fb_sig_user => @user.facebook_id, :challenge => @params
      assert !assigns(:challenge).blank?
      assert_equal "1v0", assigns(:challenge).challenge_type
    end    
    assert flash[:error]
    assert flash[:error_message]
  end
  
  def test_edit
    challenge = challenges(:siamese_persian_issued)
    pet = challenge.defender
    mock_user_facebooking(pet.user.facebook_id)
    facebook_get :edit, :fb_sig_user => pet.user.facebook_id, :id => challenge.id
    assert_response :success
    assert_template 'edit'
    assert !assigns(:challenge).blank?
    assert !assigns(:pet).blank?    
    assert_tag :tag => "form", :attributes => { :action => @controller.facebook_nested_url(facebook_challenge_path) }, :descendant => {
      :tag => "input", :attributes => { :name => "_method", :type => "hidden", :value => "put" }
    }
    assert_tag :tag => "form", :descendant => { :tag => "table", :attributes => { :class => "comparison-table" }}
    assert_tag :tag => "form", :descendant => { :tag => "td", :attributes => { :class => "battle-gear" }}
    assert_tag :tag => "form", :descendant => { :tag => "input", :attributes => { :type => "submit" }}
    assert_tag :tag => "form", :descendant => {:tag=>"input",:attributes=>{:type=>"checkbox",:name=>"defender_strategy_attributes[status]"} }
  end
  
  def test_update
    challenge = challenges(:siamese_persian_issued)
    mock_user_facebooking(@defender.user.facebook_id)
    params = {:defender_strategy_attributes => { :maneuvers_attributes => { "0" => {:action_id => actions(:scratch).id}} }}
    assert_difference ['Battle.count'], +1 do
      facebook_put :update, :fb_sig_user => @defender.user.facebook_id, :id => challenge.id, :challenge => params
      assert_response :success
      assert !assigns(:challenge).blank?    
      assert !assigns(:challenge).battle.blank?
    end
  end

  def test_update_open
    challenge = challenges(:burmese_open)
    mock_user_facebooking(@defender.user.facebook_id)
    params = {:defender_strategy_attributes => { :maneuvers_attributes => { "0" => {:action_id => actions(:scratch).id}} }}
    assert_difference ['Battle.count'], +1 do
      facebook_put :update, :fb_sig_user => @defender.user.facebook_id, :id => challenge.id, :challenge => params
      assert_response :success
      assert !assigns(:challenge).blank?    
      assert !assigns(:challenge).battle.blank?
    end
  end
  
  def test_refuse
    challenge = challenges(:siamese_persian_issued)
    pet = challenge.defender
    mock_user_facebooking(pet.user.facebook_id)
    facebook_put :refuse, :fb_sig_user => pet.user.facebook_id, :id => challenge.id
    assert_response :success
    assert !assigns(:challenge).blank?
    assert_equal 'refused', challenge.reload.status
  end

  def test_cancel
    challenge = challenges(:siamese_persian_issued)
    pet = challenge.attacker
    mock_user_facebooking(pet.user.facebook_id)
    facebook_put :cancel, :fb_sig_user => pet.user.facebook_id, :id => challenge.id
    assert_response :success
    assert !assigns(:challenge).blank?
    assert_equal 'canceled', challenge.reload.status
  end
  
  def test_create_parameter_injection
    @exploiter = pets(:burmese)
    @params[:attacker_strategy_attributes][:combatant_id] = @exploiter.id
    facebook_post :create, :fb_sig_user => @user.facebook_id, :pet_id => @defender.id, :challenge => @params
    assert !assigns(:challenge).blank?
    assert_equal @attacker.id, assigns(:challenge).attacker_strategy.combatant_id
  end
end