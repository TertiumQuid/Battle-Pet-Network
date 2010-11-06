module Facebook::BelongingsHelper
  def link_to_belonging(belonging)
    case belonging.item.item_type
      when 'Food'
        if belonging.status == "holding"
          facebook_link_to 'eat', facebook_belonging_path(belonging), :method => :put
        else
          "eaten"
        end
      when 'Toy'
        if belonging.status == "holding"
          facebook_link_to 'practice-play', facebook_belonging_path(belonging), :method => :put
        else
          "tattered"
        end
      when 'Weapon','Collar','Sensor','Mantle'
        if belonging.status == "holding"
          facebook_link_to 'equip', facebook_belonging_path(belonging), :method => :put
        elsif belonging.status == "active"
          facebook_link_to 'remove', facebook_belonging_path(belonging), :method => :put
        end
      when 'Ornament'
        "decorative"
      when 'Charm'
        if belonging.status == "holding"
          facebook_link_to 'wear', facebook_belonging_path(belonging), :method => :put
        else
          facebook_link_to 'remove', facebook_belonging_path(belonging), :method => :put
        end
      when 'Standard'
        "for pack"
    end
  end
end