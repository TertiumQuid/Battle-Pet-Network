require 'test_helper'

class SignTest < ActiveSupport::TestCase
  def setup
    @sender = pets(:siamese)
    @recipient = pets(:russian_blue)
  end
  
  def test_signs_with
    assert !Sign.signs_with( pets(:siamese), @new_pet).blank?
  end
  
  def test_hiss
    assert_difference '@recipient.reload.current_endurance', -5 do
      assert_difference '@sender.reload.current_endurance', -5 do    
        signing = @sender.signings.build(:recipient => @recipient, :sign_type => 'hiss')
        signing.save
      end
    end
  end

  def test_play
    @recipient.update_attribute(:current_endurance,1)
    assert_difference '@recipient.reload.current_endurance', +3 do
      assert_difference '@sender.reload.current_endurance', -3 do    
        signing = @sender.signings.build(:recipient => @recipient, :sign_type => 'play')
        signing.save
      end
    end
  end

  def test_purr
    @recipient.update_attribute(:current_endurance,1)
    assert_difference '@recipient.reload.current_endurance', +1 do
      assert_difference '@sender.reload.current_endurance', -1 do    
        signing = @sender.signings.build(:recipient => @recipient, :sign_type => 'purr')
        signing.save
      end
    end
  end

  def test_groom
    @recipient.update_attribute(:current_health,1)
    assert_difference '@recipient.reload.current_health', +1 do
      assert_difference '@sender.reload.current_endurance', -3 do    
        signing = @sender.signings.build(:recipient => @recipient, :sign_type => 'groom')
        signing.save
      end
    end
  end
  
  def test_verb
    Sign::SIGNINGS.each do |s|
      assert_not_nil Sign.new(:sign_type => 'purr').verb
    end
  end

  def test_effects
    Sign::SIGNINGS.each do |s|
      assert_not_nil Sign.new(:sign_type => 'purr', :sender => Pet.first, :recipient => Pet.last).effects
    end
  end
  
  def test_validates_endurance_cost
    @sender.update_attribute(:current_endurance, 0)  
    signing = @sender.signings.build(:recipient => @recipient, :sign_type => 'purr')
    rescue_save(signing)
    assert_equal "not enough endurance", signing.errors.on(:sender_id)
  end
  
  def test_validates_once_per_day
    existing = @sender.signings.build(:recipient => @recipient, :sign_type => 'purr')
    existing.save(false)
    signing = existing.sender.signings.build(:recipient => existing.recipient, :sign_type => 'purr')
    rescue_save(signing)
    assert_equal "already sent a sign today", signing.errors.on(:recipient_id)
  end
end