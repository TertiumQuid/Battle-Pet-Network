class ActivityStream < ActiveRecord::Base
  serialize :activity_data

  belongs_to :actor, :polymorphic => true
  belongs_to :object, :polymorphic => true
  belongs_to :indirect_object, :polymorphic => true

  validates_presence_of :category, :namespace
  validates_inclusion_of :category, :in => %w(analytics combat humans packs social awards shopping world items hunting)
  
  after_validation_on_create :set_polymorph_data
  after_validation_on_create :set_description_data
  after_create :send_notifications
  
  SQL_RECENT = "created_at >= DATE_ADD(NOW(), INTERVAL -7 DAY)"
  
  named_scope :world_activity, :conditions => "category = 'world'", :order => "created_at DESC ", :limit => 12
  named_scope :sentient_activity, :conditions => "category = 'hunting' OR (category = 'world' AND namespace = 'repopulation')"
  named_scope :pet_activity, :conditions => "(category = 'combat' AND namespace = 'battled') OR " <<
                                            "(category = 'humans' AND namespace = 'tame') OR " <<
                                            "(category = 'packs' AND (namespace = 'founded' OR namespace = 'joined')) OR " <<
                                            "(category = 'hunting' AND namespace = 'hunted') OR " <<
                                            "(category = 'analytics' AND namespace = 'pet') ",
                             :order => "created_at DESC ",
                             :limit => 15
      
  class << self
    def log!(category,namespace,actor=nil,object=nil,indirect_object=nil,data={})
      return true if AppConfig.logging != 1
      return create!(:category => category, 
                    :namespace => namespace, 
                    :actor => actor,
                    :object => object,
                    :indirect_object => indirect_object,
                    :activity_data => data)
    end
  end
  
  def after_initialize(*args)
    self.activity_data ||= {}
  end

  def set_polymorph_data
    ['actor','object','indirect_object'].each do |model|
      m = self.send(model.to_sym)
      next if m.blank?

      self.activity_data["#{model}_name".to_sym] = 
        case m.class.name
          when 'User'
            send(model.to_sym).normalized_name
          when 'Pet'
            send(model.to_sym).name
        end
    end
  end

  def send_notifications
  end
  
  def set_description_data
    actor_name = activity_data[:actor_name]
    object_name = activity_data[:object_name]
    indirect_object_name = activity_data[:indirect_object_name]
    self.activity_data[:description] = 
      case category
        when 'combat'
          case namespace
            when 'challenge-1v1'
              "#{actor_name} challenged #{object_name} to batttle."
            when 'challenge-1v0'
              "#{actor_name} made an open challenge to battle."
            when 'challenge-1vG'
              "#{actor_name} challenged pack #{object_name} to battle."
            when 'refused'
              "#{actor_name} refused to battle #{object_name}."
            when 'battled'
              indirect_object.outcome
          end
        when 'humans'
          case namespace
            when 'discover'
              "#{actor_name} discovered the human called #{object_name}, but could not tame them."
            when 'tame'
              "#{actor_name} discovered the human called #{object_name} and tamed them."
            when 'release'
              "#{actor_name} released their human #{object_name} and returned them to the freedom of the wild"
            when 'murder'
              "#{actor_name}'s kenneled humans grew violent, and #{indirect_object_name} killed #{object_name}."
            when 'scavenged'
              "#{actor_name} scavenged a #{object_name} for #{indirect_object_name}."
          end
        when 'items'
          case namespace
            when 'scavenging'
              "#{actor_name} was out scavenging when they discovered a #{object_name}."
            when 'scavenged'
              "#{actor_name} went scavenging and discovered a #{object_name}."
            when 'foraging'
              "#{actor_name} was out foraging when they discovered a #{object_name}."
            when 'foraged'
              "#{actor_name} went foraging and discovered a #{object_name}."
          end
        when 'hunting'
          case namespace
            when 'hunted'
              "#{actor_name} hunted a #{object_name} and #{indirect_object.hunter.outcome}."
          end
        when 'packs'
          case namespace
            when 'founded'
              "#{actor_name} founded a pack."
            when 'paid-dues'
              "#{actor_name} paid dues for its members."
            when 'unpaid-dues'
              "#{actor_name} could not pay kibble for its members and became insolvent."
            when 'request'
              "#{actor_name} wishes to join the pack #{object_name}."
            when 'joined'
              "#{actor_name} joined the pack #{object_name}."
            when 'spoils'
              "#{actor_name} handed over a #{object_name} to the spoils of #{indirect_object_name}."
          end
        when 'social'
          case namespace
            when 'message'
              "#{actor_name} sent a message to #{object_name}."
            when 'sign'
              "#{actor_name} #{indext_object.verb} #{object_name}."
          end
        when 'awards'
          case namespace
            when 'ranked'
              "#{actor_name} ranked ##{object.rank} on the #{indirect_object_name} leaderboard"
            when 'leveled'  
              "#{actor_name} advanced to level #{object.rank} and gained #{object.advancement_amount} #{object.advancement_type}."
          end
        when 'shopping'
          case namespace
            when 'market'
              "#{actor_name} got a #{object_name} from the market."
            when 'purchase'  
              "#{actor_name} got a #{object_name} from #{indirect_object.name}'s shop."
            when 'stocking'
              "#{actor_name} added a #{object_name} to their shop."
            when 'unstocking'
              "#{actor_name} removed a #{object_name} from their shop."
            when 'opened'
              "#{actor_name} opened a shop named #{object_name}."
          end
        when 'world'
          case namespace
            when 'repopulation'
              "Sentient numbers repopulated."
            when 'restock'
              "Market stores restocked inventory."
            when 'leaderboards'
              "Pet leaderboard rankings updated."
          end
        when 'analytics'
          case namespace
            when 'registration'
              "#{actor_name} visited."
            when 'conversion'
              "#{actor_name} befriended the pet #{object_name}."
            when 'pet'
              "#{actor_name} entered the world."
            when 'referer'
              "#{object_name} entered the world on your recommendation."
            when 'daily-login'
              "#{actor_name} found #{AppConfig.awards.daily_login} kibble after signing in."
            when 'invitation'
              "#{actor_name} invited friends to join."
          end
      end
  end
end