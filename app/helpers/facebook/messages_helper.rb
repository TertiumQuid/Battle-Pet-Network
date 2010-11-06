module Facebook::MessagesHelper
  def message_icon(message)
    if current_user_pet.id = message.sender_id
      facebook_image_tag("ui/messages/sent-message.png")
    else
      new_part = message.read? ? "" : "new-"
      facebook_image_tag("ui/messages/#{new_part}#{message.message_type}-message.png")
    end
  end
end