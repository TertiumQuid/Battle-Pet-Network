module Facebook::LobbyHelper
  def invitation_link
    "pets/new?canvas=true&referer_id=#{(current_user ? current_user.id : nil)}"
  end
end