module Facebook::HuntsHelper
  def link_to_hunt(sentient)
    if !has_pet?
      ""
    elsif sentient.population < 1
      "Depopulated"
    elsif current_user_pet.level_rank_count < sentient.required_rank
      "Requires Level #{sentient.required_rank}"
    else
      facebook_link_to 'Hunt It', new_facebook_sentient_hunt_path(sentient), :class => 'button green'
    end
  end
end