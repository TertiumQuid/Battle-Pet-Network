require 'test_helper'

class AwardTest < ActiveSupport::TestCase
  def test_description
    Award::AWARD_TYPES.each do |t|
      award = Award.find_by_award_type(t)
      next unless award
      assert !award.description.blank?
    end
  end
  
  def test_award_rankable
    @pet = pets(:siamese)
    @pack = packs(:alpha)
    @shop = shops(:first)
    @rankables = [@pet,@pack,@shop]
    Award::AWARD_TYPES.each do |t|
      award = Award.find_by_award_type(t)
      next unless award
      @rankables.each do |r|
        if award.award_type == 'kibble'
          assert_difference [(r.respond_to?(:kibble) ? 'r.kibble' : 'r.pet.kibble')], +award.prize.to_i do
            award.award_rankable(r)
          end
        end
      end
    end
  end
end