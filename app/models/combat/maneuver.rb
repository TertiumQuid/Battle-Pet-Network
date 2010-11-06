class Maneuver < ActiveRecord::Base
  belongs_to :strategy
  belongs_to :action
  
  validates_presence_of :rank, :action_id
  validates_numericality_of :rank  
  
  accepts_nested_attributes_for :action, :allow_destroy => false
end