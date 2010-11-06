class Facebook::FacebookController < ApplicationController
  include ApplicationHelper
  include Facebook::FacebookHelper
  layout 'facebook'
  
  helper_method :has_pet?, :has_shop?, :has_pack?, :has_facebook_user?, :application_is_installed?, 
                :facebook_redirect_to, :stored_location, :facebook_app_path, :application_tweets_html
  
  before_filter :ensure_facebook_request, :set_facebook_user
  after_filter :store_location
  
  filter_parameter_logging :fb_sig_friends
  
  def application_tweets_html
    return "&nbsp;" if AppConfig.tweets.to_i != 1
    return @application_tweets if defined?(@application_tweets)
    
    twitter = Twitter::TweetsToHtml.new
    @application_tweets = twitter.to_html
    return @application_tweets
  end
  
  # # #
  # pet or user (or anonymous) authentication questions for display
  # # #    
  
  def has_pet?
    current_user_pet && current_user_pet != nil
  end

  def has_shop?
    current_user_pet && !current_user_pet.shop_id.blank?
  end

  def has_pack?
    current_user_pet && !current_user_pet.pack_id.blank?
  end
  
  def has_facebook_user?
    return (facebook_session != nil && facebook_session.secured?)
  end
  
  # # #
  # overrides to handle facebook routing and the 'facebook' routes namespace  
  # # #  
  
  def facebook_path_scrub(url)
    return url.gsub('facebook/', '').gsub('/facebook', '')
  end
  
  def facebook_app_path
    Facebooker.current_adapter.facebooker_config['canvas_page_name']
  end
  
  def facebook_redirect_to(url)
    redirect_to url.blank? ? '' : facebook_path_scrub(url)
  end  
  
  def store_location
    app_root = facebook_app_path
    fb_path = facebook_path_scrub(request.request_uri)
    stored = "/#{app_root}#{fb_path}"
    session[:return_to] = stored if request.method.to_s == 'get'
  end

  def stored_location
    return session[:return_to] || facebook_path_scrub(facebook_root_path)
  end

  def redirect_facebook_back
    redirect_to stored_location, :status => :ok
  end
  
  def ensure_facebook_request
    unless request_comes_from_facebook?
      render :file => "#{RAILS_ROOT}/public/401.html", :status => :unauthorized
      return false
    end
  end
  
  def ensure_has_pet
    unless has_pet?
      render :file => "#{RAILS_ROOT}/public/401.html", :status => :unauthorized
      return false
    end
  end
  
  def set_facebook_user
    if request_comes_from_facebook?
      set_facebook_session 
      
      # if the session is secured then the we have a valid facebook user id
      if has_facebook_user?
        @current_user ||= User.from_facebook(facebook_session.user.uid.to_i,facebook_session)
      end
    end
  end
  
  # # #
  # handling various invalid requests gracefully in facebook
  # # #
    
  rescue_from ActionController::MethodNotAllowed, :with => :rescue_from_missing_method

  def rescue_from_missing_method(exception)
    facebook_redirect_to facebook_root
  end
  
protected 

  def render_optional_error_file(status_code) 
    render :template => "facebook/500", :status => 500, :layout => false
  end   
end