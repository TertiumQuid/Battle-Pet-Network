require 'test_helper'

class Facebook::BiographiesControllerTest  < ActionController::TestCase
  include Facebooker::Rails::TestHelpers
  
  def setup
    @pet = pets(:persian)
    @params = {:temperament => 'Aloof', :lifestyle => 'Indoor', :gender => 'Tom', :favorite_color => 'Blue',
               :favorite_food => 'Treats', :favorite_pastime => 'Playing', :favorite_season => 'Spring',
               :favorite_philosopher => 'Descartes', :favorite_composer => 'J.S. Bach',
               :pedigree => 'Purebred', :circadian => 'Nocturnal', :voice => 'Smooth', :zodiac => 'Mouser',
               :birthday => '2010-1-1', :siblings => 2, :description => 'Test pet. Test pet. Test pet. Test pet. Test pet. Test pet. Test pet.'}    
  end

  def test_new
    mock_user_facebooking(@pet.user.facebook_id)
    facebook_get :new, :fb_sig_user => @pet.user.facebook_id

    assert_response :success
    assert_template 'new'
    assert_tag :tag => "form", :descendant => { :tag => "table", :attributes => { :class => "biography" } }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[temperament]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[lifestyle]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[gender]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[favorite_color]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[favorite_food]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[favorite_pastime]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[favorite_season]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[favorite_philosopher]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[favorite_composer]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[pedigree]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[circadian]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[voice]"} }
    assert_tag :tag => "form", :descendant => { :tag => "select", :attributes => {:name => "biography[zodiac]"} }
    assert_tag :tag => "form", :descendant => { :tag => "textarea", :attributes => {:name => "biography[description]"} }
    assert_tag :tag => "form", :descendant => { :tag => "input", :attributes => { :type => "submit" } }
  end

  def test_create
    mock_user_facebooking(@pet.user.facebook_id)
    assert_difference 'Biography.count', +1 do
      facebook_post :create, :fb_sig_user => @pet.user.facebook_id, :biography => @params
    end
    assert_response :success, "response should be a success"
    assert_not_nil @pet.reload.biography, "biography should create for pet"
  end
  
  def test_fail_create
    mock_user_facebooking(@pet.user.facebook_id)
    assert_no_difference 'Biography.count' do
      facebook_post :create, :fb_sig_user => @pet.user.facebook_id, :biography => {}
    end
    assert_response :success
    assert assigns(:biography).new_record?
    assert !flash[:error].blank?
    assert !flash[:error_message].blank?
  end
end