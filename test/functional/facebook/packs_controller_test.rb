require 'test_helper'

class Facebook::PacksControllerTest < ActionController::TestCase     
  include Facebooker::Rails::TestHelpers
  
  def setup
    @user = users(:three)
    @pet = @user.pet
    @standard = items(:fiberboard_pillar)
    @params = {:founder_id => @pet.id, :name => 'test pack', :standard_id => @standard.id}
    @leader = packs(:alpha).leader
    @member = pack_members(:alpha_member).pet
  end
  
  def test_index
    mock_user_facebooking
    facebook_get :index, :fb_sig_user => nil
    assert_response :success
    assert_template 'index'
  end
  
  def test_get_pack
    mock_user_facebooking
    facebook_get :show, :id => packs(:alpha).id, :fb_sig_user => nil
    assert_response :success
    assert_template 'show'
    assert !assigns(:pack).blank?
    assert !assigns(:pack).pack_members.blank?
    assert_tag :tag => "div", :attributes => { :id => "spoils" }
    assert_tag :tag => "td", :attributes => { :class => "pack-member" }
    assert_no_tag :tag => "span", :attributes => { :id => "challenge-button" }
    assert_no_tag :tag => "span", :attributes => { :id => "membership-button" }
  end

  def test_get_pack_with_pet
    mock_user_facebooking(users(:three).facebook_id)
    facebook_get :show, :id => packs(:alpha).id, :fb_sig_user => users(:three).facebook_id
    assert_response :success
    assert_template 'show'
    assert !assigns(:pack).blank?
    assert !assigns(:pack).pack_members.blank?
    assert_tag :tag => "div", :attributes => { :id => "spoils" }
    assert_tag :tag => "td", :attributes => { :class => "pack-member" }
    assert_tag :tag => "span", :attributes => { :id => "challenge-button" }
    assert_tag :tag => "a", :attributes => { :href => "/pets/home/messages/new?message_type=membership&amp;pet_id=#{packs(:alpha).leader_id}" }
  end
  
  def test_get_new_pack
    pet = @user.pet
    pet.belongings.create(:item_id => items(:fiberboard_pillar).id, :source => 'purchased')
    
    mock_user_facebooking(@user.facebook_id)
    facebook_get :new, :fb_sig_user => @user.facebook_id
    assert_response :success
    assert_template 'new'
    assert !assigns(:pack).blank?
    assert !assigns(:standards).blank?
    assert_tag :tag => "form", :descendant => { 
      :tag => "input", :attributes => { :name => "pack[standard_id]", :type => "radio" },  
      :tag => "table", :attributes => { :id => "item-picker" },
      :tag => "ul", :attributes => { :class => "items" },
      :tag => "input", :attributes => { :type => "submit" }
    }
  end

  def test_create
    mock_user_facebooking(@user.facebook_id)
    @pet.update_attribute(:kibble, AppConfig.packs.founding_fee)
    assert_difference 'Pack.count', +1 do
      facebook_post :create, :pack => @params, :fb_sig_user => @user.facebook_id
      assert_response :success
      assert !assigns(:pack).blank?
    end    
    assert flash[:success]
    assert_equal assigns(:pack).id, @pet.reload.pack_id
  end

  def test_fail_create
    mock_user_facebooking(@user.facebook_id)
    @pet.update_attribute(:kibble, AppConfig.packs.founding_fee - 1)
    assert_no_difference 'Pack.count' do
      facebook_post :create, :pack => @params, :fb_sig_user => @user.facebook_id
      assert_response :success
      assert !assigns(:pack).blank?
    end    
    assert flash[:error]
    assert flash[:error_message]
  end
  
  def test_get_edit
    mock_user_facebooking(@leader.user.facebook_id)
    facebook_get :edit, :fb_sig_user => @leader.user.facebook_id
    assert_response :success
    assert_template 'edit'
    assert !assigns(:pack).blank?
    assert assigns(:items)
    assert_tag :tag => "form", :attributes => {:id => 'donate-items'}
    assert_tag :tag => "form", :attributes => {:id => 'donate-kibble'}
    assert_tag :tag => "form", :attributes => {:class => 'loan-spoils'}
    assert_tag :tag => "form", :attributes => {:class => 'invite-form'}
    assert_tag :tag => "form", :descendant => {
      :tag => "input", :attributes => { :type => "hidden", :value => "disbanded" },
      :tag => "input", :attributes => { :type => "submit" }
    }
  end
  
  def test_disband
    mock_user_facebooking(@leader.user.facebook_id)
    facebook_put :update, :fb_sig_user => @leader.user.facebook_id, :pack => {:status => 'disbanded'}
    assert_response :success
    pack = assigns(:pack)
    assert !pack.blank?
    assert pack.disbanded?
  end

  def test_disband_fail
    mock_user_facebooking(@member.user.facebook_id)
    facebook_put :update, :fb_sig_user => @member.user.facebook_id, :pack => {:status => 'disbanded'}
    assert_response :success
    pack = assigns(:pack)
    assert !pack.blank?
    assert !pack.disbanded?
  end
  
  def test_invite
    recipient = pets(:persian)
    mock_user_facebooking(@leader.user.facebook_id)
    [recipient.name,recipient.slug].each do |invittee|
      assert_difference 'Message.count', +1 do
        facebook_post :invite, :fb_sig_user => @leader.user.facebook_id, :invittee => invittee
        assert !assigns(:pack).blank?
        assert !assigns(:pet).blank?
        assert flash[:notice]
      end
    end
  end
end