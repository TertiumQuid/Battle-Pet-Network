class CreateCore < ActiveRecord::Migration
  def self.up
    create_table :species do |t|
      t.string :name, :null => false, :limit => 64
    end

    create_table :breeds do |t|
      t.belongs_to :species, :null => false
      t.belongs_to :favorite_action, :null => false
      t.string :name, :null => false, :limit => 128
      t.string :description, :limit => 2048
      t.integer :health, :null => false, :default => 1
      t.integer :endurance, :null => false, :default => 1
      t.integer :power, :null => false, :default => 1
      t.integer :intelligence, :null => false, :default => 1
      t.integer :fortitude, :null => false, :default => 1
      t.integer :affection, :null => false, :default => 1
    end
    add_index :breeds, [:species_id]
    
    create_table :levels do |t|
      t.belongs_to :breed, :null => false
      t.integer :experience, :default => 0, :null => false
      t.integer :rank, :null => false
      t.integer :advancement_amount, :default => 0, :null => false
      t.string :advancement_type, :null => false
    end
    add_index :levels, [:breed_id,:rank]
    add_index :levels, [:breed_id,:experience]
    
    create_table :actions do |t|
       t.belongs_to :species, :null => false
       t.string :name, :null => false, :limit => 32
       t.string :action_type, :null => false, :limit => 32
       t.string :verb, :limit => 128
       t.integer :power, :null => false
    end
    add_index :actions, [:species_id,:action_type]
    add_index :actions, [:action_type]
    
    create_table :actions_breeds, :id => false do |t|
      t.belongs_to :action, :null => false
      t.belongs_to :breed, :null => false
    end    
    add_index :actions_breeds, [:breed_id, :action_id], :unique => true
    
    create_table :actions_pets, :id => false do |t|
      t.belongs_to :action, :null => false
      t.belongs_to :pet, :null => false
    end
    add_index :actions_pets, [:pet_id, :action_id], :unique => true
    
    create_table :strategies do |t|
      t.belongs_to :combatant, :null => false, :polymorphic => true
      t.string :name, :null => false
      t.string :status, :limit => 32, :null => false, :default => 'active'
      t.timestamps
    end
    add_index :strategies, [:combatant_id,:combatant_type,:status]
    
    create_table :maneuvers do |t|
      t.integer :rank, :default => 0
      t.belongs_to :action, :null => false
      t.belongs_to :strategy, :null => false
    end
    add_index :maneuvers, [:strategy_id, :rank]
   
    create_table :users do |t| 
      t.belongs_to :pet
      t.belongs_to :referer
      t.column :facebook_id, :bigint, :limit => 8      
      t.string :iphone_udid, :limit => 512
      t.string :username, :limit => 128
      t.string :first_name, :limit => 128
      t.string :last_name, :limit => 128
      t.string :email, :limit => 512
      t.string :gender, :limit => 32
      t.string :facebook_session_key
      t.string :persistence_token
      t.string :timezone, :limit => 32, :default => 'UTC +00:00'
      t.string :locale, :limit => 16, :default => 'en_US'
      t.string :role, :limit => 128, :default => 'member'
      t.string :signature, :limit => 512
      t.datetime :birthday
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.datetime :last_request_at

      t.timestamps
    end
    add_index :users, [:facebook_id]
    add_index :users, [:iphone_udid]
    add_index :users, [:current_login_at]

    create_table :occupations do |t|
      t.string :name, :null => false, :limit => 64
      t.string :description, :limit => 512
      t.integer :cost, :default => 0, :null => false
    end
    add_index :occupations, [:name]

    create_table :pets do |t|
      t.string :name, :null => false, :limit => 64
      t.string :slug, :null => false, :limit => 32
      t.string :status, :limit => 32, :null => false, :default => 'active'
      t.integer :current_health, :default => 0, :null => false
      t.integer :current_endurance, :default => 0, :null => false
      t.integer :health, :default => 0, :null => false
      t.integer :endurance, :default => 0, :null => false
      t.integer :power, :default => 0, :null => false
      t.integer :health_bonus_count, :default => 0, :null => false
      t.integer :endurance_bonus_count, :default => 0, :null => false
      t.integer :power_bonus_count, :default => 0, :null => false
      t.integer :fortitude_bonus_count, :default => 0, :null => false
      t.integer :defense_bonus_count, :default => 0, :null => false
      t.integer :affection_bonus_count, :default => 0, :null => false
      t.integer :intelligence_bonus_count, :default => 0, :null => false
      t.integer :intelligence, :default => 0, :null => false
      t.integer :fortitude, :default => 0, :null => false
      t.integer :affection, :default => 0, :null => false
      t.integer :experience, :default => 0, :null => false
      t.integer :wins_count, :default => 0, :null => false
      t.integer :loses_count, :default => 0, :null => false
      t.integer :draws_count, :default => 0, :null => false
      t.integer :level_rank_count, :default => 1, :null => false
      t.integer :kibble, :default => 0, :null => false
      t.belongs_to :breed, :null => false
      t.belongs_to :user
      t.belongs_to :pack
      t.belongs_to :shop
      t.belongs_to :level
      t.belongs_to :occupation
      t.belongs_to :rival
      t.belongs_to :mate
      t.belongs_to :favorite_action
      t.timestamps
    end
    add_index :pets, [:user_id,:status]
    add_index :pets, [:occupation_id,:level_rank_count,:status]
    add_index :pets, [:slug], :unique => true
     
    create_table :biographies do |t|
      t.belongs_to :pet
      t.string :temperament, :limit => 64, :null => false
      t.string :lifestyle, :limit => 32, :null => false
      t.string :gender, :limit => 32, :null => false
      t.string :favorite_color, :limit => 32, :null => false
      t.string :favorite_food, :limit => 32, :null => false       
      t.string :favorite_pastime, :limit => 32, :null => false              
      t.string :favorite_season, :limit => 32, :null => false 
      t.string :favorite_composer, :limit => 64, :null => false
      t.string :favorite_philosopher, :limit => 64, :null => false                  
      t.string :pedigree, :limit => 32, :null => false
      t.string :circadian, :limit => 32, :null => false       
      t.string :voice, :limit => 32, :null => false
      t.string :zodiac, :limit => 64, :null => false                            
      t.string :description, :limit => 2048
      t.integer :siblings, :null => false    
      t.datetime :birthday   
      t.datetime :created_at
    end
    add_index :biographies, [:pet_id], :unique => true 
    
    create_table :packs do |t|
      t.belongs_to :founder, :null => false
      t.belongs_to :leader
      t.belongs_to :standard, :null => false
      t.string :name, :limit => 64, :null => false
      t.integer :kibble, :null => false, :default => 0
      t.string :status, :null => false, :default => 'active'
      t.integer :pack_members_count, :default => 0
      t.timestamps
    end
    add_index :packs, [:leader_id]
    add_index :packs, [:pack_members_count]
    
    create_table :pack_members do |t|
      t.belongs_to :pack, :null => false
      t.belongs_to :pet, :null => false
      t.string :position, :null => false, :default => 'member'
      t.string :status, :null => false, :default => 'active'
      t.string :message, :limit => 256
      t.timestamps
    end
    add_index :pack_members, [:pack_id,:status,:created_at]
    add_index :pack_members, [:pet_id,:created_at]
    
    create_table :challenges do |t|
      t.string :status, :null => false, :default => "issued"
      t.string :challenge_type, :null => false, :default => "1v1"
      t.string :message, :limit => 256
      t.belongs_to :attacker, :null => false
      t.belongs_to :attacker_strategy, :null => false
      t.belongs_to :defender
      t.belongs_to :defender_strategy
      t.timestamps
    end
    add_index :challenges, [:attacker_id,:defender_id,:status]
    add_index :challenges, [:defender_id,:attacker_id,:status]
    add_index :challenges, [:created_at]
    
    create_table :battles do |t|
      t.belongs_to :challenge, :null => false
      t.belongs_to :winner
      t.text :logs
      t.datetime :created_at
    end
    add_index :battles, [:challenge_id]
    add_index :battles, [:winner_id]
    
    create_table :sentients do |t|
      t.string :sentient_type, :null => false
      t.string :name, :null => false
      t.string :description, :limit => 512
      t.integer :health, :default => 0, :null => false
      t.integer :endurance, :default => 0, :null => false
      t.integer :power, :default => 0, :null => false
      t.integer :intelligence, :default => 0, :null => false
      t.integer :fortitude, :default => 0, :null => false
      t.integer :kibble, :default => 0, :null => false
      t.integer :population, :default => 0, :null => false
      t.integer :repopulation_rate, :default => 1, :null => false
      t.integer :population_cap, :default => 10, :null => false
      t.integer :required_rank, :default => 1, :null => false
    end
    add_index :sentients, [:population,:required_rank]
    
    create_table :hunts do |t|
      t.belongs_to :sentient, :null => false
      t.string :status, :null => false, :default => "started"
      t.text :logs
      t.timestamps :updated_at
    end
    add_index :hunts, [:sentient_id,:status,:created_at]
    add_index :hunts, [:status,:created_at]
    
    create_table :hunters do |t|
      t.belongs_to :hunt, :null => false
      t.belongs_to :pet, :null => false
      t.belongs_to :strategy, :null => false
      t.string :outcome, :null => false
    end
    add_index :hunters, [:pet_id,:hunt_id], :unique => true
    add_index :hunters, [:hunt_id]
    
    create_table :humans do |t|
      t.string :name, :null => false, :limit => 64
      t.string :human_type, :null => false, :limit => 32
      t.integer :difficulty, :default => 1, :null => false
      t.integer :power, :default => 0, :null => false
      t.integer :cost, :default => 0, :null => false
      t.integer :required_rank, :default => 1, :null => false      
      t.string :description, :limit => 1024
    end
    add_index :humans, [:required_rank,:power]
    add_index :humans, [:human_type]
    
    create_table :tames do |t|
      t.belongs_to :pet, :null => false
      t.belongs_to :human, :null => false
      t.string :status, :limit => 32, :null => false, :default => 'active'
      t.timestamps
    end
    add_index :tames, [:pet_id,:human_id,:status]
    add_index :tames, [:status]
    
    create_table :collections do |t|
      t.string :name, :null => false
      t.integer :items_count, :default => 0, :null => false
    end
    add_index :collections, [:name]
    
    create_table :items do |t|
      t.belongs_to :species
      t.belongs_to :collection
      t.string :name, :null => false, :limit => 64
      t.string :item_type, :null => false, :limit => 64
      t.string :description, :limit => 1024
      t.integer :power, :default => 0, :null => false
      t.integer :required_rank, :default => 0, :null => false
      t.integer :cost, :default => 0, :null => false
      t.integer :rarity, :default => 10, :null => false
      t.integer :stock, :default => 0, :null => false
      t.integer :restock_rate, :default => 1, :null => false
      t.integer :stock_cap, :default => 3, :null => false
      t.boolean :exclusive, :default => false
      t.boolean :premium, :default => false
    end
    add_index :items, [:species_id,:required_rank,:rarity]
    add_index :items, [:item_type,:premium,:stock,:power]
    add_index :items, [:collection_id]
    
    create_table :shops do |t|
      t.belongs_to :pet, :null => false
      t.belongs_to :featured_item
      t.string :name, :null => false, :limit => 128
      t.string :status, :limit => 32, :null => false, :default => 'active'
      t.string :specialty, :null => false, :limit => 128
      t.string :description, :limit => 512
      t.integer :inventories_count, :null => false, :default => 0
      t.datetime :last_restock_at  
      t.timestamps
    end
    add_index :shops, [:pet_id,:status]
    add_index :shops, [:inventories_count,:status]
    add_index :shops, [:specialty,:status]
    
    create_table :inventories do |t|
      t.belongs_to :shop, :null => false
      t.belongs_to :item, :null => false
      t.integer :cost, :null => false
      t.timestamps
    end
    add_index :inventories, [:item_id]
    add_index :inventories, [:shop_id,:item_id,:cost]
    
    create_table :spoils do |t|
      t.belongs_to :pack, :null => false
      t.belongs_to :item, :null => false
      t.belongs_to :pet
      t.string :status, :limit => 32, :null => false, :default => 'active'
      t.timestamps
    end
    add_index :spoils, [:pack_id,:status]
    
    create_table :belongings  do |t|
      t.belongs_to :item, :null => false
      t.belongs_to :pet, :null => false
      t.string :source, :limit => 32, :null => false
      t.string :status, :limit => 32, :null => false, :default => 'active'
      t.timestamps
    end
    add_index :belongings, [:pet_id,:status]
    add_index :belongings, [:item_id]
    
    create_table :loans do |t|
      t.belongs_to :spoil, :null => false
      t.belongs_to :belonging, :null => false
    end
    add_index :loans, [:spoil_id,:belonging_id], :unique => true
    
    create_table :leaderboards do |t|
      t.string :rankable_type, :null => false
      t.string :name, :null => false
      t.string :description, :limit => 512
      t.integer :ranked_count, :default => 25, :null => false
      t.datetime :updated_at
    end
    add_index :leaderboards, [:rankable_type]
    
    create_table :awards do |t|
      t.belongs_to :leaderboard, :null => false
      t.string :award_type, :null => false, :limit => 32
      t.string :prize, :null => false, :limit => 64
      t.integer :rank, :null => false
    end
    add_index :awards, [:leaderboard_id,:rank]
    
    create_table :rankings do |t|
      t.belongs_to :leaderboard, :null => false
      t.datetime :created_at
    end
    add_index :rankings, [:leaderboard_id,:created_at]
    
    create_table :ranks do |t|
      t.belongs_to :ranking, :null => false
      t.belongs_to :rankable, :null => false, :polymorphic => true
      t.integer :rank, :default => 1, :null => false
      t.integer :score, :default => 1
    end
    add_index :ranks, [:ranking_id]
    add_index :ranks, [:rankable_id,:rankable_type]
    
    create_table :badges do |t|
      t.string :name, :limit => 64, :null => false
      t.string :description, :limit => 512, :null => false
    end
    
    create_table :badges_pets do |t|
      t.belongs_to :badge, :null => false
      t.belongs_to :pet, :null => false
      t.timestamps
    end
    add_index :badges_pets, [:badge_id,:pet_id], :unique => true
            
    create_table :comments do |t|
      t.belongs_to :pet, :null => false
      t.belongs_to :parent, :polymorphic => true, :null => false
      t.string :body, :null => false, :limit => 4096
      t.timestamps
    end
    add_index :comments, [:pet_id]
    add_index :comments, [:parent_id,:parent_type,:created_at]
    
    create_table :signs do |t|
       t.belongs_to :sender, :null => false
       t.belongs_to :recipient, :null => false
       t.string :sign_type, :null => false, :limit => 32
       t.timestamps
    end
    add_index :signs, [:sender_id,:recipient_id,:created_at]
    add_index :signs, [:sign_type,:created_at]
    
    create_table :messages do |t|
       t.belongs_to :sender, :null => false
       t.belongs_to :recipient, :null => false
       t.string :subject, :null => false, :limit => 128
       t.string :body, :null => false, :limit => 4096
       t.string :status, :limit => 32, :null => false, :default => 'new'
       t.string :message_type, :limit => 32, :null => false, :default => 'personal'
       t.timestamps
    end
    add_index :messages, [:sender_id,:created_at]
    add_index :messages, [:recipient_id,:created_at]
    
    create_table :activity_streams do |t|
      t.boolean :new, :null => false, :default => false
      t.belongs_to :actor, :polymorphic => true
      t.belongs_to :object, :polymorphic => true
      t.belongs_to :indirect_object, :polymorphic => true
      t.string :category, :limit => 32
      t.string :namespace, :limit => 128
      t.text :activity_data
      t.datetime :created_at
    end
    add_index :activity_streams, [:actor_id, :actor_type, :created_at], :name => :activity_streams_by_actor
    add_index :activity_streams, [:object_id, :object_type, :created_at], :name => :activity_streams_by_object
    add_index :activity_streams, [:indirect_object_id, :indirect_object_type, :created_at], :name => :activity_streams_by_indirect
    
    create_table :forums, :force => true do |t|
      t.belongs_to :last_post, :null => false
      t.string :name, :limit => 128, :null => false
      t.string :description, :limit => 255
      t.string :forum_type, :limit => 32, :null => false, :default => 'user'
      t.integer :forum_topics_count, :default => 0
      t.integer :forum_posts_count, :default => 0
      t.integer :rank, :default => 0      
      t.datetime :created_at
    end

    create_table :forum_topics, :force => true do |t|
      t.belongs_to :forum, :null => false
      t.belongs_to :user, :null => false
      t.belongs_to :last_post
      t.string :title, :null => false, :limit => 128
      t.integer :forum_posts_count, :default => 0
      t.integer :views_count, :default => 0
      t.boolean :locked, :default => false
      t.boolean :sticky, :default => false
      t.timestamps
    end

    create_table :forum_posts, :force => true do |t|
      t.belongs_to :forum_topic, :null => false
      t.belongs_to :user
      t.text :body, :null => false
      t.timestamps
    end    
    
    create_table :payment_orders do |t|
      t.belongs_to :item, :null => false
      t.belongs_to :user, :null => false
      t.string :ip_address
      t.string :payer_id
      t.string :ack
      t.string :email
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :phone
      t.string :country
      t.string :city
      t.float :total, :null => false
      t.timestamps
    end
    add_index :payment_orders, [:user_id,:created_at]
    add_index :payment_orders, [:created_at]
    
    create_table :payment_order_transactions do |t|
      t.belongs_to :payment_order, :null => false
      t.string :action
      t.integer :amount
      t.boolean :success, :null => false, :default => false
      t.string :authorization
      t.string :message
      t.text :params
      t.timestamps
    end
    add_index :payment_order_transactions, [:payment_order_id]
    add_index :payment_order_transactions, [:created_at]
  end
  
  def self.down
    drop_table :payment_order_transactions
    drop_table :payment_orders
    drop_table :forum_posts
    drop_table :forum_topics
    drop_table :forums
    drop_table :activity_streams
    drop_table :messages
    drop_table :signs
    drop_table :comments
    drop_table :badges_pets
    drop_table :badges
    drop_table :ranks
    drop_table :rankings
    drop_table :awards
    drop_table :leaderboards
    drop_table :loans
    drop_table :belongings
    drop_table :spoils
    drop_table :inventories
    drop_table :shops
    drop_table :items
    drop_table :tames
    drop_table :humans
    drop_table :hunters
    drop_table :hunts
    drop_table :sentients
    drop_table :battles
    drop_table :challenges
    drop_table :pack_members
    drop_table :packs
    drop_table :biographies
    drop_table :pets
    drop_table :occupations
    drop_table :users
    drop_table :maneuvers
    drop_table :strategies
    drop_table :actions_pets
    drop_table :actions_breeds
    drop_table :actions
    drop_table :levels
    drop_table :breeds
    drop_table :species
  end  
end