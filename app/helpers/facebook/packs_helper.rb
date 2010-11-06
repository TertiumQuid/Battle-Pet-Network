module Facebook::PacksHelper
  def can_user_pet_challenge(pack)
    has_pet? && pack.id != current_user_pet.id
  end
  
  def can_user_pet_be_member(pack)
    has_pet? && !has_pack?
  end
end