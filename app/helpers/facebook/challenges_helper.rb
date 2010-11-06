module Facebook::ChallengesHelper
  def challenge_outcome_description_for(challenge,pet)
    description = "#{time_ago_in_words(challenge.created_at)} ago"
    
    is_attacker = (challenge.attacker_id == pet.id)
    description = is_attacker ? "#{description} you challenged #{challenge.defender.name} " : " #{description} #{challenge.defender.name} challenged you "
    
    case challenge.status
      when 'refused'
        description = is_attacker ? "#{description} but the coward refused to battle." : "#{description} but you declined to battle."
      when 'canceled'
        description = is_attacker ? "#{description} but you canceled the challenge." : "#{description} but they canceled the challenge before you battled."
      when 'resolved'
        if challenge.battle.winner_id.blank?
          description = "#{description} and you battled to a draw."
        else
          description = (challenge.battle.winner_id == pet.id) ? "#{description} and you defeated them in battle." : "#{description} but they defeated you in battle."
        end
      when 'expired'
        description = "#{description} but the challenge expired before you battled."
    end
    return description
  end
  
  def challenge_opposing_pet_from(challenge,pet)
    opposing_pet = (pet.id == challenge.attacker_id) ? challenge.defender : challenge.attacker
    return opposing_pet
  end  
  
  def details_bar_row(first,second,order='left')
    if order == 'left'
  	  "<tr><td>#{percentage_bar([first,second])}</td><td>#{first}</td></tr>"
	  else
  	  "<tr><td>#{first}</td><td>#{percentage_bar([first,second])}</td></tr>"
    end
  end
end