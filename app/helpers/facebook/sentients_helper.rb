module Facebook::SentientsHelper
  def sentient_badge(sentient, *args, &proc)
    options = args.last.is_a?(Hash) ? args.pop : {}
    html = "<table class='long-badge'>" <<
           "<thead>" <<
              "<tr><th colspan='3'>#{facebook_link_to(sentient.name, facebook_sentient_path(sentient))}</th></tr>" <<
            "</thead>" <<
            "<tbody>" <<
            "<tr>" <<
              "<td rowspan='4'>" <<
              avatar_image(sentient,'medium') <<
              "</td>" <<
              "<td><label>Health: <span>#{sentient.health}</span></td>" <<
              "<td rowspan='4'><em>#{sentient.description}</em></td>" <<
            "</tr>" <<            
            "<tr><td><label>Endurance: <span>#{sentient.endurance}</span></td></tr>" <<
            "<tr><td><label>Power: <span>#{sentient.power}</span></td></tr>" <<
            "<tr><td><label>Level: <span>#{sentient.required_rank}</span></td></tr>"
            
    concat(html)
    if proc
      concat("<tfoot><tr><td colspan='3'>")
      proc.call(sentient)
      concat("</tr></td></tfoot>")
    end
    concat("</table>")            
  end
end