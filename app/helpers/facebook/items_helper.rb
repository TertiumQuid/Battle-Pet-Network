module Facebook::ItemsHelper
  def item_store_table(item_type, alt)
    avatar_path = "items/types/medium/#{item_type.downcase}.png"
    return "<table class='item-store'>" <<
      "<tr><td rowspan='3'>#{facebook_image_tag(avatar_path, :title => alt)}</td>" <<
      "<td><strong>#{item_type} Store</strong></td></tr>" <<
      "<tr><td>#{pluralize(Item.type_is(item_type).in_stock.count, 'types')}<br />#{Item.type_is(item_type).in_stock.sum(:stock)} in stock</td></tr>" <<
      "<tr><td>#{facebook_link_to('Go Shopping',store_facebook_item_path(item_type), :class => 'button gray small')}</td></tr>" <<
      "</table>"
  end
  
  def item_badge(item, *args, &proc)
    options = args.last.is_a?(Hash) ? args.pop : {}
    html = "<table class='badge'>" <<
           "<thead>" <<
              "<tr><th colspan='3'>#{item.name}</th></tr>" <<
            "</thead>" <<
            "<tbody>" <<
            "<tr>" <<
              "<td rowspan='4'>" <<
              avatar_image(item,'small') <<
              "</td>" <<
              "<td><label>Type: <span>#{item.item_type}</span></td>" <<
            "</tr>" <<
            "<tr><td><label>Power: <span>#{item.power}</span></td></tr>" <<
            "<tr><td><label>Rarity: <span>#{item.cost}</span></td></tr>" <<
            "<tr><td><label>Cost: <span>#{item.cost}</span></td></tr>"
            
    html = html + "<tr><td colspan='3'><em>#{item.description}</em></td></tr>" if options[:description]
    concat(html)
    if proc
      concat("<tfoot><tr><td colspan='3'>")
      proc.call(item)
      concat("</tr></td></tfoot>")
    end
    concat("</table>")
  end
end