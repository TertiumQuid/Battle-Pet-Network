class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "Pet", :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => "Pet", :foreign_key => "recipient_id"
  
  validates_presence_of :sender_id, :recipient_id, :subject, :body, :status, :message_type
  validates_length_of :subject, :within => 2..128
  validates_length_of :body, :within => 1..4096  
  validates_inclusion_of :status, :in => %w(new read deleted)
  validates_inclusion_of :message_type, :in => %w(personal membership system)
  
  before_validation_on_create :set_status, :set_recipient
  
  cattr_reader :per_page
  @@per_page = 25
  
  attr_accessor :recipient_name, :reply_to_id
  
  class << self
    def find_for_pet(id,pet,mark_read=false)
      message = Message.find(:first, :conditions => "id = #{id} AND (#{pet.id} = sender_id OR #{pet.id} = recipient_id)")
      message.set_read! if mark_read && message.status == 'new'
      return message
    end
  end
  
  def after_initialize(*args)
    self.message_type ||= 'personal'
    
    if !reply_to_id.blank?
      reply_to = Message.find(reply_to_id, :select => 'id,message_type,sender_id')
      self.recipient = reply_to.sender
    end
  end  
  
  def validate
    errors.add(:sender_id, "can not message self") if !sender_id.blank? && (sender_id == recipient_id)
  end  
  
  def set_status
    self.status = 'new'
  end
  
  def set_recipient
    self.recipient ||= Pet.slug_or_name_equals(self.recipient_name).first unless recipient_name.blank? 
    self.recipient_id ||= recipient.id unless recipient.blank?
    @recipient_name ||= recipient.slug unless recipient.blank?
  end
  
  def read?
    message.status == 'read'
  end
  
  def set_read!
    update_attribute(:status,'read')
  end

  def set_deleted!
    update_attribute(:status,'deleted')
  end
end