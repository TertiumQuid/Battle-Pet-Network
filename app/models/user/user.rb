class User < ActiveRecord::Base
  ROLES = ['member','staff','developer','admin']
  
  belongs_to :pet
  has_many :pets
  has_many :forum_posts
  has_many :payment_orders
  
  validates_presence_of :role
  validates_inclusion_of :role, :in => ROLES
  
  acts_as_authentic do |c|
    c.login_field = :username
    c.validate_login_field = false
    c.validate_email_field = false
    c.require_password_confirmation = false
    c.validate_password_field = false
    c.password_salt_field = nil
    c.crypted_password_field = nil
  end
  
  class << self
    def from_facebook(id,facebook_session=nil)
      returning find_or_create_by_facebook_id(id) do |user|
        unless facebook_session.nil? 
          user.update_from_facebook_session_key(facebook_session.session_key)
          user.update_from_facebook_session(facebook_session)
          user.save
        end 
      end
    end
  end

  def after_initialize(*args)
    self.role ||= 'member'
  end
  
  def normalized_name
    username || (first_name.blank? ? "mysterio" : "#{first_name} #{last_name}")
  end
  
  def facebook_friend_ids
    []
  end
  
  def update_from_facebook_session_key(session_key) 
    if facebook_session_key != session_key
      self.facebook_session_key = session_key
      self.last_login_at = (current_login_at || Time.now)
      self.last_request_at = Time.now
      self.current_login_at = Time.now
    end
  end
    
  def update_from_facebook_session(facebook_session)
    return unless email.blank?
    
    facebook_session.user.populate
    self.username ||= facebook_session.user.name
    self.email = facebook_session.user.proxied_email
    self.gender = facebook_session.user.sex
    self.locale = facebook_session.user.locale
  end
  
  def staff?
    ['staff','developer','admin'].include?(role) 
  end
end