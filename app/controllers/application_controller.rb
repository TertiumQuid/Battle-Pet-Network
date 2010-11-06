# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user_session, :current_user, :current_user_pet, :registered?
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  def current_user_pet
    return @current_user_pet if defined?(@current_user_pet)
    @current_user_pet = registered? && current_user.pet
  end
  
  def registered?
    !current_user.blank?
  end
end
