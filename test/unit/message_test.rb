require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @sender = pets(:siamese)
    @recipient = pets(:persian)
    @params = {:subject => 'test', :body => 'test', :sender_id => @sender.id, :recipient_id => @recipient.id}
  end
  
  def test_set_status
    message = Message.new(@params)
    assert message.save
    assert_equal 'new', message.status
  end
  
  def test_cannot_message_self
    message = Message.new(@params)
    message.recipient_id = message.sender_id
    message.validate
    assert_not_nil message.errors.on(:sender_id)
  end
  
  def test_set_recipient
    message = Message.new(@params)
    message.recipient_id = nil
    message.recipient_name = pets(:persian).slug
    assert message.save, message.errors.full_messages
    assert_not_nil message.recipient_id
  end
  
  def test_reply_to
    reply_to = messages(:first)
    message = Message.new(:reply_to_id => reply_to.id)
    assert_equal reply_to.sender_id, message.recipient_id
    message.save
    assert_equal reply_to.sender.slug, message.recipient_name
  end
  
  def test_mark_read
    assert_equal 'new', messages(:first).status
    message = Message.find_for_pet(messages(:first).id, messages(:first).recipient)
    assert_equal 'new', message.status
    message = Message.find_for_pet(messages(:first).id, messages(:first).recipient,true)
    assert_equal 'read', message.status
  end
end