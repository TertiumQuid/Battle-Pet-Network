require 'test_helper'

class OccupationTest < ActiveSupport::TestCase
  def setup
    @pet = pets(:siamese)
    @human = humans(:oscar)
    @item = items(:cat_grass)
    @toy = items(:spiked_yarn_ball)
    @taming = occupations(:taming)
    @scavenging = occupations(:scavenging)
    @foraging = occupations(:foraging)
  end
  
  def test_tame_human
    Tame.destroy_all
    flexmock(Human).should_receive(:finds_human?).and_return(true)
    flexmock(Human).should_receive(:find_random_human).and_return(@human)
    flexmock(Tame).should_receive(:pet_tames_human?).and_return(true)
    assert_difference '@pet.tames.count', +1 do
      @taming.tame_human(@pet)
    end
  end

  def test_forage_item
    flexmock(Item).should_receive(:forages?).and_return(true)
    flexmock(Item).should_receive(:find_random_item).and_return(@item)
    assert_difference '@pet.belongings.count', +1 do
      @foraging.forage_item(@pet)
    end
  end
  
  def test_scavenge_item
    flexmock(Item).should_receive(:scavenges?).and_return(true)
    flexmock(Item).should_receive(:find_random_item).and_return(@toy)
    assert_difference '@pet.belongings.count', +1 do
      @scavenging.scavenge_item(@pet)
    end
  end
  
  def test_perform_for_pet
    flexmock(@taming).should_receive(:tame_human).and_return(true)
    flexmock(@scavenging).should_receive(:scavenge_item).and_return(true)
    [@scavenging,@taming].each do |o|
      assert o.perform_for_pet(@pet)
    end
  end
  
  def test_do_for_pet
    flexmock(@taming).should_receive(:tame_human).and_return(true)
    flexmock(@scavenging).should_receive(:scavenge_item).and_return(true)
    [@scavenging,@taming].each do |o|
      assert_difference '@pet.current_endurance', -o.cost do      
        assert o.do_for_pet!(@pet)
      end
    end
  end
  
  def test_scavenge
    flexmock(Item).should_receive(:scavenges?).and_return(true)
    flexmock(Item).should_receive(:find_random_item).and_return(@item)
    
    Pet.update_all( "occupation_id = '#{@scavenging.id}'" )
    Pet.all.each { |pet| pet.belongings.clear }  
    assert_difference ['ActivityStream.count'], +Pet.all.count do
      Occupation.scavenge!
    end
    Pet.all.each do |p|
      assert_equal 1, p.belongings.size
    end
  end 

  def test_tame_humans
    flexmock(Human).should_receive(:finds_human?).and_return(true)
    flexmock(Human).should_receive(:find_random_human).and_return(@human)
    flexmock(Tame).should_receive(:pet_tames_human?).and_return(true)

    Pet.update_all( "occupation_id = '#{@taming.id}'" )
    Pet.all.each { |pet| pet.tames.clear }  
    Occupation.tame_humans!
    Pet.all.each do |p|
      assert_equal 1, p.tames.size
    end
  end 
end