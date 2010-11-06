require 'test_helper'

class Facebook::PetsControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @pet = pets(:siamese)
    @user = @pet.user
    @shop = shops(:first)
  end
  
  def test_get_pet
    mock_user_facebooking
    facebook_get :show, :id => pets(:siamese).id, :fb_sig_user => nil
    assert_response :success
    assert_template 'show'
    assert assigns(:pet)
    assert_tag :tag => "div", :attributes => { :class => 'box gear' }
    assert_tag :tag => "div", :attributes => { :class => 'box pack' }
    assert_tag :tag => "div", :attributes => { :class => 'box humans' }
    assert_tag :tag => "table", :attributes => { :class => 'kennels' }
  end
  
  def test_get_pet_for_user
    mock_user_facebooking(@user.facebook_id)
    facebook_get :show, :id => pets(:persian).id, :fb_sig_user => @user.facebook_id
    assert_response :success
    assert_template 'show'
    assert assigns(:pet)
    Sign.signs_with(@user.pet, pets(:persian).id).each do |sign|
      assert_tag :tag => "form", :attributes => {:method => "post", :action => @controller.facebook_nested_url(facebook_pet_signs_path(pets(:persian))) }
    end
    assert_tag :tag => "a", :attributes => { :href => "/pets/home/messages/new?pet_id=#{pets(:persian).id}" }
  end
    
  def test_get_new_pet
    mock_user_facebooking(users(:one).facebook_id)
    facebook_get :new, :fb_sig_user => users(:one).facebook_id
    assert_response :success
    assert_template 'new'
    assert assigns(:pet)
    assert assigns(:breeds)
    assert_tag :tag => "table", :attributes => { :class => "breed-details" }
    assert_tag :tag => "form", :descendant => { :tag => "input", :attributes => { :name => "pet[breed_id]", :type => "hidden" }}
    assert_tag :tag => "form", :descendant => { :tag => "div", :attributes => { :class => "breed-picker" }}
    assert_tag :tag => "form", :descendant => { :tag => "input", :attributes => { :type => "submit" }}
    assert_tag :tag => "form", :descendant => { :tag => "input", :attributes => { :type => "hidden", :id => "pet_breed_id" }}
    assert_tag :tag => "img", :attributes => { :id => "breed-details-image" }
  end
  
  def test_create_pet
    mock_user_facebooking(users(:one).facebook_id)
    pet_params = {:name=>"Lilly", :breed_id=>breeds(:persian).id}
    assert_difference 'Pet.count', +1, "pet should create under expected normal conditions but had errors" do
      facebook_post :create, :pet => pet_params, :fb_sig_user => users(:one).facebook_id
      assert_response :success
      assert flash[:success]
    end
  end
  
  def test_fail_create_pet
    mock_user_facebooking(users(:one).facebook_id)
    pet_mock = flexmock(Pet)
    pet_mock.new_instances.should_receive(:save).and_return(false)
    
    pet_params = {:name=>"Lilly", :breed_id=>breeds(:persian).id}
    assert_no_difference 'Pet.count' do
      facebook_post :create, :pet => pet_params, :fb_sig_user => users(:one).facebook_id
      assert_response :success
      assert assigns(:pet)
      assert assigns(:breeds)
      assert assigns(:breed)
      assert_template 'new'
      assert flash[:error]
      assert flash[:error_message]
    end
  end
  
  def test_index_without_pet
    mock_user_facebooking
    facebook_get :index
    assert_response :success
    assert_template 'index'
    assert !assigns(:pets).blank?
    assert assigns(:pets).select {|p| p.status != 'active' }.blank?
    assert_tag :tag => "form", :descendant => {
      :tag => "div", :attributes => { :class => "filters" },
      :tag => "input", :attributes => { :type => "text" }
    }
  end
  
  def test_index_with_pet
    mock_user_facebooking(users(:one).facebook_id)
    facebook_get :index, :fb_sig_user => users(:one).facebook_id
    assert_response :success
    assert_template 'index'
    assert !assigns(:pets).blank?
    assert_tag :tag => "form", :descendant => {
      :tag => "div", :attributes => { :class => "filters" },
      :tag => "input", :attributes => { :type => "text" }
    }
  end
  
  def test_search_index
    mock_user_facebooking(users(:one).facebook_id)
    facebook_get :index, :fb_sig_user => users(:one).facebook_id, :search => @pet.slug
    assert_response :success
    assert_template 'index'
    assert !assigns(:pets).blank?
    assert_equal 1, assigns(:pets).size
  end
  
  def test_combat_profile
    @pet.update_attribute(:favorite_action_id,nil)
    c = challenges(:siamese_persian_issued)
    c.attacker = pets(:persian)
    c.attacker_strategy = pets(:persian).strategies.first
    c.defender = pets(:siamese)
    c.save(false)
    
    mock_user_facebooking(@user.facebook_id)
    facebook_get :combat, :fb_sig_user => @user.facebook_id
    assert_response :success
    assert_template 'combat'
    assert !assigns(:pet).blank?
    assert !assigns(:levels).blank?
    assert !assigns(:resolved).blank?
    assert !assigns(:challenges).blank?
    assert !assigns(:strategies).blank?
    assert assigns(:gear)
    assert_tag :tag => "table", :attributes => { :id => "combat-profile" }
    assert_tag :tag => "table", :attributes => { :class => "records challenges" }
    assert_tag :tag => "table", :attributes => { :id => "advancements" }
    assert_tag :tag => "a", :attributes => { :href => @controller.facebook_nested_url(facebook_challenges_path) }
    assert_tag :tag => "table", :attributes => { :class => "challenge" }, :descendant => {
      :tag => "a", :attributes => { :href => "/pets/home/challenges/#{assigns(:challenges).first.id}/refuse"}
    }
    assert_tag :tag => "table", :attributes => { :class => "challenge" }, :descendant => {
      :tag => "a", :attributes => { :href => "/pets/home/challenges/#{assigns(:challenges).first.id}/edit"}
    }
    assert_tag :tag => "div", :attributes => { :class => "box gear" }
    assert_tag :tag => "form", :descendant => { :tag => "input", :attributes => { :name => "_method", :type => "hidden", :value => "put" }}
    assert_tag :tag => "a", :attributes => { :href => @controller.facebook_nested_url(open_facebook_challenges_path) }
    assert_tag :tag => "a", :attributes => { :href => @controller.facebook_nested_url(facebook_occupations_path) }
  end
  
  def test_update
    mock_user_facebooking(@user.facebook_id)
    facebook_put :update, :fb_sig_user => @user.facebook_id
    assert_response :success
  end
  
  def test_update_favorite_action
    @pet.update_attribute(:favorite_action_id, nil)
    scratch = actions(:scratch)
    
    mock_user_facebooking(@pet.user.facebook_id)
    facebook_put :update, :fb_sig_user => @pet.user.facebook_id, :pet => {:favorite_action_id => scratch.id}
    assert_response :success
    assert flash[:notice]
    assert_equal scratch.id, @pet.reload.favorite_action_id
  end
  
  def test_update_occupation
    occupation = occupations(:shopkeeping)
    mock_user_facebooking(@pet.user.facebook_id)
    facebook_put :update, :fb_sig_user => @pet.user.facebook_id, :pet => {:occupation_id => occupation.id}
    assert_response :success
    assert flash[:notice]
    assert_equal occupation.id, @pet.reload.occupation_id
  end
  
  def test_fail_update_favorite_action
    scratch = actions(:scratch)
    claw = actions(:claw)
    @pet.update_attribute(:favorite_action_id, claw.id)
    mock_user_facebooking(@pet.user.facebook_id)
    facebook_put :update, :fb_sig_user => @pet.user.facebook_id, :pet => {:favorite_action_id => scratch.id}
    assert_response :success
    assert flash[:error]
    assert_equal claw.id, @pet.reload.favorite_action_id
  end

  def test_retire
    mock_user_facebooking(@user.facebook_id)
    facebook_delete :retire, :fb_sig_user => @user.facebook_id
    assert_response :success
    assert flash[:notice]    
    assert_nil @user.reload.pet
  end
  
  def test_profile
    @shop.update_attribute(:pet_id, @pet.id)
    @pet.update_attribute(:shop_id, @shop.id)
    mock_user_facebooking(@user.facebook_id)
    facebook_get :profile, :fb_sig_user => @user.facebook_id
    assert_response :success
    assert_template 'profile'
    assert !assigns(:pet).blank?
    assert !assigns(:messages).blank?
    assert !assigns(:signs).blank?
    assert !assigns(:items).blank?
    assert !assigns(:shop).blank?
    assert_tag :tag => "div", :attributes => { :class => "box slim biography" }
    assert_tag :tag => "div", :attributes => { :class => "box shop" }, :descendant => {
      :tag => "a", :attributes => { :href => @controller.facebook_nested_url(edit_facebook_shop_path) }
    }
    assert_tag :tag => "form", :attributes => { :action => "/#{@controller.facebook_app_path}/pets/home/pet"}, :descendant => {
      :tag => "input", :attributes => { :name => "_method", :type => "hidden", :value => "put" }
    }
    assert_tag :tag => "div", :attributes => { :class => "box slim retire"}, :descendant => {
      :tag => "a", :attributes => { :href => @controller.facebook_nested_url(retire_facebook_pet_path) }
    }
  end
  
  def test_ensure_no_pet
    mock_user_facebooking(@user.facebook_id)
    facebook_get :new, :fb_sig_user => @user.facebook_id
    assert flash[:alert]
    facebook_get :create, :fb_sig_user => @user.facebook_id
    assert flash[:alert]
  end
end