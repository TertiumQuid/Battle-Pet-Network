require 'test_helper'

class PackTest < ActiveSupport::TestCase
  def setup
    @pet = pets(:siamese)
    @pack = packs(:alpha)
    @founder = pets(:persian)
    @standard = items(:fiberboard_pillar)
    @params = {:founder_id => @founder.id, :name => 'test pack', :standard_id => @standard.id}
  end
  
  def test_recover
    Pet.connection.execute( "UPDATE pets SET current_endurance = 1 " )
    Pack.recover!
    Pack.active.all.each do |p|
      p.pack_members.each do |m|
        assert_equal p.membership_bonus + 1, m.pet.current_endurance
      end
    end
  end
  
  def test_pay_dues
    starting = 100
    Pack.connection.execute( "UPDATE packs SET kibble = #{starting} " )
    assert_difference 'ActivityStream.count', +Pack.credited.count do
      Pack.pay_dues!
    end
    Pack.active.all.each do |p|
      assert_equal starting - p.membership_dues, p.kibble
    end
    
    Pack.connection.execute( "UPDATE packs SET kibble = 0 " )
    assert_difference 'ActivityStream.count', +Pack.credited.count do
      Pack.pay_dues!
    end
    Pack.active.all.each do |p|
      assert_equal 'insolvent', p.status
    end
  end

  def test_validates_founder
    pack = Pack.new(:founder_id => @pet.id, :name => 'test pack', :standard_id => @standard.id)
    rescue_save(pack)
    assert @pet.pack_id
    assert pack.errors.on(:founder_id)
  end
  
  def test_validates_standard
    not_owned = items(:sisal_mast)
    assert !@pet.belongings.map(&:item).include?(not_owned)
    pack = Pack.new(:founder_id => @pet.id, :name => 'test pack', :standard_id => not_owned.id)
    rescue_save(pack)
    assert pack.errors.on(:standard_id)
  end
  
  def test_validates_founding_fee
    fee = AppConfig.packs.founding_fee
    @founder.update_attribute(:kibble, fee - 1)
    pack = Pack.new(@params)
    rescue_save(pack)
    assert pack.errors.on(:kibble)
  end
  
  def test_set_leader
    pack = Pack.new(@params)
    rescue_save(pack)
    assert pack.founder_id && pack.leader_id
    assert_equal pack.founder_id, pack.leader_id
  end
  
  def test_updates_founder
    @founder.update_attribute(:kibble, AppConfig.packs.founding_fee)
    pack = Pack.new(@params)
    pack.send(:after_save)
    assert_equal pack.id, @founder.pack_id
  end
  
  def test_position_for
    stranger = pets(:persian)
    member = pets(:burmese)
    pack = packs(:alpha)
    assert_equal pack.founder_id, @pet.id
    assert_not_equal pack.id, stranger.pack_id
    assert_equal 'leader', pack.position_for(@pet)
    assert_equal 'member', pack.position_for(member)
    assert_equal nil, pack.position_for(stranger)
  end
  
  def test_battle_record
    wins = 0
    loses = 0
    draws = 0
    @pack.pack_members.each do |m|
      wins = wins + m.pet.wins_count
      loses = loses + m.pet.loses_count
      draws = draws + m.pet.draws_count
    end
    assert_equal "#{wins}/#{loses}/#{draws}", @pack.battle_record
  end
  
  def test_membership_bonus
    members = @pack.pack_members
    ranks = members.collect(&:pet).collect(&:level_rank_count)
    total = 0
    ranks.each do |r|
      total = total + r
    end
    total = total * AppConfig.packs.member_bonus_modifier
    assert_equal @pack.membership_bonus, total
  end
  
  def test_contribute_kibble
    contribution = 25
    assert_difference '@pack.kibble', +contribution do    
      @pack.kibble_contribution = contribution
      @pack.save(false)
    end
  end
  
  def test_invite_membership
    recipient = pets(:persian)
    assert_difference 'Message.count', +1 do
      message = @pack.invite_membership(@pet,recipient)
      assert message
      assert_not_nil message.body
      assert_not_nil message.subject
      assert_not_nil message.id
      assert_equal @pet, message.sender
      assert_equal recipient, message.recipient
    end
  end
  
  def test_fail_invite_membership
    recipient = pets(:burmese)
    assert_no_difference 'Message.count' do
      message = @pack.invite_membership(@pet,recipient)
      assert message.errors.on(:recipient_id)
      message = packs(:beta).invite_membership(@pet,recipient)
      assert message.errors.on(:sender_id)
    end
  end
  
  def test_disband
    assert_difference '@pack.leader.kibble', +@pack.kibble do
      assert @pack.disband!
    end
    assert_equal 0, @pack.kibble
    assert_equal 'disbanded', @pack.status
    @pack.pack_members.each do |m|
      assert_equal 'disbanded', m.status
      assert_nil m.pet.pack_id
    end
  end

  def test_log_founding
    pack = Pack.new(@params)
    @founder.update_attribute(:kibble, AppConfig.packs.founding_fee)
    assert_difference 'ActivityStream.count', +1 do
      assert pack.save!
    end
  end
end