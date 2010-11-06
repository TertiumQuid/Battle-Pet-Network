class Spoil < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  belongs_to :pack
  belongs_to :item
  belongs_to :pet
  
  def acquired
    if pet_id
      "provided by #{pet.name} #{time_ago_in_words(created_at)} ago"
    else
      ""
    end
  end
end