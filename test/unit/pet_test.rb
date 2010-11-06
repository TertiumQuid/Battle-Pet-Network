require 'test_helper'

class PetTest < ActiveSupport::TestCase
  def setup
    mock_user_facebooking
    
    @user = users(:one)
    @new_pet = Pet.new(:name => 'lilly', :breed_id => breeds(:persian).id, :user_id => @user.id)
    @pet = pets(:siamese)
  end
  
  def test_set_slug
    assert @new_pet.save
    assert_not_nil @new_pet.slug
  end
  
  def test_set_occupation
    assert @new_pet.save
    assert_not_nil @new_pet.reload.occupation
  end
  
  def test_set_user
    assert @new_pet.save
    assert_equal @new_pet.id, @user.reload.pet_id
  end
  
  def test_populate_from_breed
    breed = breeds(:persian)
    @new_pet.populate_from_breed
  
    assert_equal breed.health, @new_pet.health
    assert_equal breed.endurance, @new_pet.endurance
    assert_equal breed.power, @new_pet.power
    assert_equal breed.intelligence, @new_pet.intelligence
    assert_equal breed.fortitude, @new_pet.fortitude
    assert_equal breed.affection, @new_pet.affection
    
    assert_equal @new_pet.health, @new_pet.current_health
    assert_equal @new_pet.endurance, @new_pet.current_endurance
  end
  
  def test_update_occupation
    occupation = occupations(:taming)
    @pet.update_occupation!(occupation.id)
    assert_equal occupation.id, @pet.reload.occupation_id
  end
  
  def test_update_favorite_action
    @pet.update_attribute(:favorite_action_id, nil)
    scratch = actions(:scratch)
    claw = actions(:claw)
    assert @pet.update_favorite_action!(scratch)
    assert !@pet.update_favorite_action!(claw)
    assert_equal "favorite action has already been chosen", @pet.errors.on(:favorite_action_id)
  end
  
  def test_is_prowling
    taming = occupations(:taming)
    prowling = occupations(:prowling)
    @pet.update_attribute(:occupation_id,prowling.id)
    assert @pet.reload.prowling?
    @pet.update_attribute(:occupation_id,taming.id)
    assert !@pet.reload.prowling?
  end
  
  def test_set_level
    assert @new_pet.save
    assert_equal 1, @new_pet.level_rank_count
    assert_not_nil @new_pet.level_id
    assert_equal @new_pet.breed.levels.first, @new_pet.level
  end
  
  def test_award_experience
     exp = 10
     assert_difference 'Pet.find(@pet).experience', +exp do
       @pet.award_experience!(exp)
     end
   end
   
   def test_slave_earnings
     Tame.destroy_all
     pet = pets(:persian)
     sarah = humans(:sarah)
     ichabod = humans(:ichabod)
     pet.tames.create(:human => sarah, :status => 'enslaved')
     pet.tames.create(:human => ichabod, :status => 'enslaved')
     expected = (sarah.power + ichabod.power) * AppConfig.humans.slavery_earnings_multiplier
     assert_equal expected, pet.slave_earnings
     Tame.destroy_all
     assert_equal 0, pet.slave_earnings
   end
  
   def test_recover
     Pet.connection.execute( "UPDATE pets SET current_endurance = 5, current_health = 1 " )
     Pet.recover!
     Pet.all.each do |p|
       assert_equal p.current_endurance, 5 + p.fortitude
       assert_equal p.current_health, p.health
     end
   end
   
   def test_last_seen
     new_pet = Pet.new
     assert_nil new_pet.last_seen
     timestamp = Time.now
     @pet.user.update_attribute(:current_login_at,timestamp)
     assert_equal timestamp, @pet.last_seen
   end
   
   def test_favorite_actions
     @pet.favorite_action = @pet.breed.favorite_action
     assert_equal "constantly #{@pet.favorite_action.name}", @pet.favorite_actions
     @pet.favorite_action = nil
     assert_equal "#{@pet.breed.favorite_action.name}", @pet.favorite_actions
     @pet.favorite_action = actions(:leap)
     assert_equal "#{@pet.breed.favorite_action.name} and #{actions(:leap).name}", @pet.favorite_actions
   end
   
   def test_battle_record
     assert @pet.battle_record.match /\d\/\d\/\d/
   end
   
   def test_retire
     assert @pet.retire!
     assert_equal "retired", @pet.status
     assert_nil @pet.user.pet
   end
   
   def test_set_actions
     assert @new_pet.save!
     assert_operator @new_pet.actions.size, ">", 0
     assert_equal @new_pet.actions.size, @new_pet.breed.species.actions.size
     @new_pet.breed.species.actions.each do |a|
       assert @new_pet.actions.include?(a)
     end
   end
end