require 'test_helper'

class TameTest < ActiveSupport::TestCase
  def setup
    @pet = pets(:siamese)
    @tamed = pets(:siamese).tames.kenneled.first
    @kenneled = @pet.tames.kenneled
    @human = humans(:sarah)
  end

  def test_validates_max_tames
    @pet.update_attribute(:affection, @pet.tames.kenneled.size)
    tame = @pet.tames.new(:human_id => humans(:oscar).id)
    tame.save
    assert tame.errors.on(:human_id).include?("max number of humans already tamed")
  end
  
  def test_validates_exclusivity
    tame = @pet.tames.new(:human_id => @tamed.human.id)
    tame.save
    assert tame.errors.on(:human_id).include?("human already tamed")
  end
  
  def test_enslaves
    @pet.tames.kenneled.enslave(@tamed.id)
    assert_equal 'enslaved', @tamed.reload.status
  end
  
  def test_releases
    release_award = @tamed.human.power * AppConfig.humans.release_multiplier
    assert_difference 'ActivityStream.count', +1 do
      assert_difference '@pet.reload.kibble', +release_award do 
        assert_difference ['@pet.tames.count','Tame.count'], -1 do
          @pet.tames.kenneled.release(@tamed.id)
        end    
      end
    end
    assert_nil Tame.find_by_id(@tamed.id)
  end
  
  def pet_tames_human
    chance = @pet.total_affection
    AppConfig.occupations.tame_human_chance_divisor = chance / 1000
    assert Tame.pet_tames_human?(@pet,@human)
    AppConfig.occupations.tame_human_chance_divisor = chance * 1000
    assert !Tame.pet_tames_human?(@pet,@human)
  end
  
  def test_kills_neighbor
    AppConfig.humans.kills_neighbor_modifier = 100  
    @kenneled.each do |t|
      assert t.kills_neighbor?(@kenneled.size)
    end
    AppConfig.humans.kills_neighbor_modifier = 0
    @kenneled.each do |t|
      assert !t.kills_neighbor?(@kenneled.size)
    end
  end
  
  def test_coexist_kills
    AppConfig.humans.kills_neighbor_modifier = 100
    assert_difference 'ActivityStream.count', +1 do
      assert_difference '@pet.tames.count', -1 do
        Tame.coexist!(@kenneled)
      end    
    end
  end
  
  def test_coexist_peace
    AppConfig.humans.kills_neighbor_modifier = 0
    assert_no_difference '@pet.tames.count' do
      Tame.coexist!(@kenneled)
    end    
  end
  
  def test_update_bonus_count_column
    Tame.destroy_all
    Human.all.each do |h|
      t = @pet.tames.build(:human => h)
      col = case h.human_type.downcase
        when 'friendly'
          'affection'
        when 'fatted'
          'health'
        when 'wise'
          'intelligence'
      end
      next unless col
      assert_difference "t.pet.#{col}_bonus_count", +h.power do
        t.update_bonus_count_column
      end 
      assert_difference "t.pet.#{col}_bonus_count", -h.power do
        t.update_bonus_count_column(-1)
      end
    end
  end
end