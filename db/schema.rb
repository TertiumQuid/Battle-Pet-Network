# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100124124827) do

  create_table "actions", :force => true do |t|
    t.integer "species_id",                 :null => false
    t.string  "name",        :limit => 32,  :null => false
    t.string  "action_type", :limit => 32,  :null => false
    t.string  "verb",        :limit => 128
    t.integer "power",                      :null => false
  end

  add_index "actions", ["action_type"], :name => "index_actions_on_action_type"
  add_index "actions", ["species_id", "action_type"], :name => "index_actions_on_species_id_and_action_type"

  create_table "actions_breeds", :id => false, :force => true do |t|
    t.integer "action_id", :null => false
    t.integer "breed_id",  :null => false
  end

  add_index "actions_breeds", ["breed_id", "action_id"], :name => "index_actions_breeds_on_breed_id_and_action_id", :unique => true

  create_table "actions_pets", :id => false, :force => true do |t|
    t.integer "action_id", :null => false
    t.integer "pet_id",    :null => false
  end

  add_index "actions_pets", ["pet_id", "action_id"], :name => "index_actions_pets_on_pet_id_and_action_id", :unique => true

  create_table "activity_streams", :force => true do |t|
    t.boolean  "new",                                 :default => false, :null => false
    t.integer  "actor_id"
    t.string   "actor_type"
    t.integer  "object_id"
    t.string   "object_type"
    t.integer  "indirect_object_id"
    t.string   "indirect_object_type"
    t.string   "category",             :limit => 32
    t.string   "namespace",            :limit => 128
    t.text     "activity_data"
    t.datetime "created_at"
  end

  add_index "activity_streams", ["actor_id", "actor_type", "created_at"], :name => "activity_streams_by_actor"
  add_index "activity_streams", ["indirect_object_id", "indirect_object_type", "created_at"], :name => "activity_streams_by_indirect"
  add_index "activity_streams", ["object_id", "object_type", "created_at"], :name => "activity_streams_by_object"

  create_table "awards", :force => true do |t|
    t.integer "leaderboard_id",               :null => false
    t.string  "award_type",     :limit => 32, :null => false
    t.string  "prize",          :limit => 64, :null => false
    t.integer "rank",                         :null => false
  end

  add_index "awards", ["leaderboard_id", "rank"], :name => "index_awards_on_leaderboard_id_and_rank"

  create_table "badges", :force => true do |t|
    t.string "name",        :limit => 64,  :null => false
    t.string "description", :limit => 512, :null => false
  end

  create_table "badges_pets", :force => true do |t|
    t.integer  "badge_id",   :null => false
    t.integer  "pet_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "badges_pets", ["badge_id", "pet_id"], :name => "index_badges_pets_on_badge_id_and_pet_id", :unique => true

  create_table "battles", :force => true do |t|
    t.integer  "challenge_id", :null => false
    t.integer  "winner_id"
    t.text     "logs"
    t.datetime "created_at"
  end

  add_index "battles", ["challenge_id"], :name => "index_battles_on_challenge_id"
  add_index "battles", ["winner_id"], :name => "index_battles_on_winner_id"

  create_table "belongings", :force => true do |t|
    t.integer  "item_id",                                        :null => false
    t.integer  "pet_id",                                         :null => false
    t.string   "source",     :limit => 32,                       :null => false
    t.string   "status",     :limit => 32, :default => "active", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "belongings", ["item_id"], :name => "index_belongings_on_item_id"
  add_index "belongings", ["pet_id", "status"], :name => "index_belongings_on_pet_id_and_status"

  create_table "biographies", :force => true do |t|
    t.integer  "pet_id"
    t.string   "temperament",          :limit => 64,   :null => false
    t.string   "lifestyle",            :limit => 32,   :null => false
    t.string   "gender",               :limit => 32,   :null => false
    t.string   "favorite_color",       :limit => 32,   :null => false
    t.string   "favorite_food",        :limit => 32,   :null => false
    t.string   "favorite_pastime",     :limit => 32,   :null => false
    t.string   "favorite_season",      :limit => 32,   :null => false
    t.string   "favorite_composer",    :limit => 64,   :null => false
    t.string   "favorite_philosopher", :limit => 64,   :null => false
    t.string   "pedigree",             :limit => 32,   :null => false
    t.string   "circadian",            :limit => 32,   :null => false
    t.string   "voice",                :limit => 32,   :null => false
    t.string   "zodiac",               :limit => 64,   :null => false
    t.string   "description",          :limit => 2048
    t.integer  "siblings",                             :null => false
    t.datetime "birthday"
    t.datetime "created_at"
  end

  add_index "biographies", ["pet_id"], :name => "index_biographies_on_pet_id", :unique => true

  create_table "breeds", :force => true do |t|
    t.integer "species_id",                                        :null => false
    t.integer "favorite_action_id",                                :null => false
    t.string  "name",               :limit => 128,                 :null => false
    t.string  "description",        :limit => 2048
    t.integer "health",                             :default => 1, :null => false
    t.integer "endurance",                          :default => 1, :null => false
    t.integer "power",                              :default => 1, :null => false
    t.integer "intelligence",                       :default => 1, :null => false
    t.integer "fortitude",                          :default => 1, :null => false
    t.integer "affection",                          :default => 1, :null => false
  end

  add_index "breeds", ["species_id"], :name => "index_breeds_on_species_id"

  create_table "challenges", :force => true do |t|
    t.string   "status",                              :default => "issued", :null => false
    t.string   "challenge_type",                      :default => "1v1",    :null => false
    t.string   "message",              :limit => 256
    t.integer  "attacker_id",                                               :null => false
    t.integer  "attacker_strategy_id",                                      :null => false
    t.integer  "defender_id"
    t.integer  "defender_strategy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "challenges", ["attacker_id", "defender_id", "status"], :name => "index_challenges_on_attacker_id_and_defender_id_and_status"
  add_index "challenges", ["created_at"], :name => "index_challenges_on_created_at"
  add_index "challenges", ["defender_id", "attacker_id", "status"], :name => "index_challenges_on_defender_id_and_attacker_id_and_status"

  create_table "collections", :force => true do |t|
    t.string  "name",                       :null => false
    t.integer "items_count", :default => 0, :null => false
  end

  add_index "collections", ["name"], :name => "index_collections_on_name"

  create_table "comments", :force => true do |t|
    t.integer  "pet_id",                      :null => false
    t.integer  "parent_id",                   :null => false
    t.string   "parent_type",                 :null => false
    t.string   "body",        :limit => 4096, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["parent_id", "parent_type", "created_at"], :name => "index_comments_on_parent_id_and_parent_type_and_created_at"
  add_index "comments", ["pet_id"], :name => "index_comments_on_pet_id"

  create_table "forum_posts", :force => true do |t|
    t.integer  "forum_topic_id", :null => false
    t.integer  "user_id"
    t.text     "body",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forum_topics", :force => true do |t|
    t.integer  "forum_id",                                            :null => false
    t.integer  "user_id",                                             :null => false
    t.integer  "last_post_id"
    t.string   "title",             :limit => 128,                    :null => false
    t.integer  "forum_posts_count",                :default => 0
    t.integer  "views_count",                      :default => 0
    t.boolean  "locked",                           :default => false
    t.boolean  "sticky",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forums", :force => true do |t|
    t.integer  "last_post_id",                                          :null => false
    t.string   "name",               :limit => 128,                     :null => false
    t.string   "description"
    t.string   "forum_type",         :limit => 32,  :default => "user", :null => false
    t.integer  "forum_topics_count",                :default => 0
    t.integer  "forum_posts_count",                 :default => 0
    t.integer  "rank",                              :default => 0
    t.datetime "created_at"
  end

  create_table "humans", :force => true do |t|
    t.string  "name",          :limit => 64,                  :null => false
    t.string  "human_type",    :limit => 32,                  :null => false
    t.integer "difficulty",                    :default => 1, :null => false
    t.integer "power",                         :default => 0, :null => false
    t.integer "cost",                          :default => 0, :null => false
    t.integer "required_rank",                 :default => 1, :null => false
    t.string  "description",   :limit => 1024
  end

  add_index "humans", ["human_type"], :name => "index_humans_on_human_type"
  add_index "humans", ["required_rank", "power"], :name => "index_humans_on_required_rank_and_power"

  create_table "hunters", :force => true do |t|
    t.integer "hunt_id",     :null => false
    t.integer "pet_id",      :null => false
    t.integer "strategy_id", :null => false
    t.string  "outcome",     :null => false
  end

  add_index "hunters", ["hunt_id"], :name => "index_hunters_on_hunt_id"
  add_index "hunters", ["pet_id", "hunt_id"], :name => "index_hunters_on_pet_id_and_hunt_id", :unique => true

  create_table "hunts", :force => true do |t|
    t.integer  "sentient_id",                        :null => false
    t.string   "status",      :default => "started", :null => false
    t.text     "logs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hunts", ["sentient_id", "status", "created_at"], :name => "index_hunts_on_sentient_id_and_status_and_created_at"
  add_index "hunts", ["status", "created_at"], :name => "index_hunts_on_status_and_created_at"

  create_table "inventories", :force => true do |t|
    t.integer  "shop_id",    :null => false
    t.integer  "item_id",    :null => false
    t.integer  "cost",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventories", ["item_id"], :name => "index_inventories_on_item_id"
  add_index "inventories", ["shop_id", "item_id", "cost"], :name => "index_inventories_on_shop_id_and_item_id_and_cost"

  create_table "items", :force => true do |t|
    t.integer "species_id"
    t.integer "collection_id"
    t.string  "name",          :limit => 64,                      :null => false
    t.string  "item_type",     :limit => 64,                      :null => false
    t.string  "description",   :limit => 1024
    t.integer "power",                         :default => 0,     :null => false
    t.integer "required_rank",                 :default => 0,     :null => false
    t.integer "cost",                          :default => 0,     :null => false
    t.integer "rarity",                        :default => 10,    :null => false
    t.integer "stock",                         :default => 0,     :null => false
    t.integer "restock_rate",                  :default => 1,     :null => false
    t.integer "stock_cap",                     :default => 3,     :null => false
    t.boolean "exclusive",                     :default => false
    t.boolean "premium",                       :default => false
  end

  add_index "items", ["collection_id"], :name => "index_items_on_collection_id"
  add_index "items", ["item_type", "premium", "stock", "power"], :name => "index_items_on_item_type_and_premium_and_stock_and_power"
  add_index "items", ["species_id", "required_rank", "rarity"], :name => "index_items_on_species_id_and_required_rank_and_rarity"

  create_table "leaderboards", :force => true do |t|
    t.string   "rankable_type",                                :null => false
    t.string   "name",                                         :null => false
    t.string   "description",   :limit => 512
    t.integer  "ranked_count",                 :default => 25, :null => false
    t.datetime "updated_at"
  end

  add_index "leaderboards", ["rankable_type"], :name => "index_leaderboards_on_rankable_type"

  create_table "levels", :force => true do |t|
    t.integer "breed_id",                          :null => false
    t.integer "experience",         :default => 0, :null => false
    t.integer "rank",                              :null => false
    t.integer "advancement_amount", :default => 0, :null => false
    t.string  "advancement_type",                  :null => false
  end

  add_index "levels", ["breed_id", "experience"], :name => "index_levels_on_breed_id_and_experience"
  add_index "levels", ["breed_id", "rank"], :name => "index_levels_on_breed_id_and_rank"

  create_table "loans", :force => true do |t|
    t.integer "spoil_id",     :null => false
    t.integer "belonging_id", :null => false
  end

  add_index "loans", ["spoil_id", "belonging_id"], :name => "index_loans_on_spoil_id_and_belonging_id", :unique => true

  create_table "maneuvers", :force => true do |t|
    t.integer "rank",        :default => 0
    t.integer "action_id",                  :null => false
    t.integer "strategy_id",                :null => false
  end

  add_index "maneuvers", ["strategy_id", "rank"], :name => "index_maneuvers_on_strategy_id_and_rank"

  create_table "messages", :force => true do |t|
    t.integer  "sender_id",                                            :null => false
    t.integer  "recipient_id",                                         :null => false
    t.string   "subject",      :limit => 128,                          :null => false
    t.string   "body",         :limit => 4096,                         :null => false
    t.string   "status",       :limit => 32,   :default => "new",      :null => false
    t.string   "message_type", :limit => 32,   :default => "personal", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["recipient_id", "created_at"], :name => "index_messages_on_recipient_id_and_created_at"
  add_index "messages", ["sender_id", "created_at"], :name => "index_messages_on_sender_id_and_created_at"

  create_table "occupations", :force => true do |t|
    t.string  "name",        :limit => 64,                 :null => false
    t.string  "description", :limit => 512
    t.integer "cost",                       :default => 0, :null => false
  end

  add_index "occupations", ["name"], :name => "index_occupations_on_name"

  create_table "pack_members", :force => true do |t|
    t.integer  "pack_id",                                         :null => false
    t.integer  "pet_id",                                          :null => false
    t.string   "position",                  :default => "member", :null => false
    t.string   "status",                    :default => "active", :null => false
    t.string   "message",    :limit => 256
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pack_members", ["pack_id", "status", "created_at"], :name => "index_pack_members_on_pack_id_and_status_and_created_at"
  add_index "pack_members", ["pet_id", "created_at"], :name => "index_pack_members_on_pet_id_and_created_at"

  create_table "packs", :force => true do |t|
    t.integer  "founder_id",                                             :null => false
    t.integer  "leader_id"
    t.integer  "standard_id",                                            :null => false
    t.string   "name",               :limit => 64,                       :null => false
    t.integer  "kibble",                           :default => 0,        :null => false
    t.string   "status",                           :default => "active", :null => false
    t.integer  "pack_members_count",               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packs", ["leader_id"], :name => "index_packs_on_leader_id"
  add_index "packs", ["pack_members_count"], :name => "index_packs_on_pack_members_count"

  create_table "payment_order_transactions", :force => true do |t|
    t.integer  "payment_order_id",                    :null => false
    t.string   "action"
    t.integer  "amount"
    t.boolean  "success",          :default => false, :null => false
    t.string   "authorization"
    t.string   "message"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_order_transactions", ["created_at"], :name => "index_payment_order_transactions_on_created_at"
  add_index "payment_order_transactions", ["payment_order_id"], :name => "index_payment_order_transactions_on_payment_order_id"

  create_table "payment_orders", :force => true do |t|
    t.integer  "item_id",     :null => false
    t.integer  "user_id",     :null => false
    t.string   "ip_address"
    t.string   "payer_id"
    t.string   "ack"
    t.string   "email"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "country"
    t.string   "city"
    t.float    "total",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_orders", ["created_at"], :name => "index_payment_orders_on_created_at"
  add_index "payment_orders", ["user_id", "created_at"], :name => "index_payment_orders_on_user_id_and_created_at"

  create_table "pets", :force => true do |t|
    t.string   "name",                     :limit => 64,                       :null => false
    t.string   "slug",                     :limit => 32,                       :null => false
    t.string   "status",                   :limit => 32, :default => "active", :null => false
    t.integer  "current_health",                         :default => 0,        :null => false
    t.integer  "current_endurance",                      :default => 0,        :null => false
    t.integer  "health",                                 :default => 0,        :null => false
    t.integer  "endurance",                              :default => 0,        :null => false
    t.integer  "power",                                  :default => 0,        :null => false
    t.integer  "health_bonus_count",                     :default => 0,        :null => false
    t.integer  "endurance_bonus_count",                  :default => 0,        :null => false
    t.integer  "power_bonus_count",                      :default => 0,        :null => false
    t.integer  "fortitude_bonus_count",                  :default => 0,        :null => false
    t.integer  "defense_bonus_count",                    :default => 0,        :null => false
    t.integer  "affection_bonus_count",                  :default => 0,        :null => false
    t.integer  "intelligence_bonus_count",               :default => 0,        :null => false
    t.integer  "intelligence",                           :default => 0,        :null => false
    t.integer  "fortitude",                              :default => 0,        :null => false
    t.integer  "affection",                              :default => 0,        :null => false
    t.integer  "experience",                             :default => 0,        :null => false
    t.integer  "wins_count",                             :default => 0,        :null => false
    t.integer  "loses_count",                            :default => 0,        :null => false
    t.integer  "draws_count",                            :default => 0,        :null => false
    t.integer  "level_rank_count",                       :default => 1,        :null => false
    t.integer  "kibble",                                 :default => 0,        :null => false
    t.integer  "breed_id",                                                     :null => false
    t.integer  "user_id"
    t.integer  "pack_id"
    t.integer  "shop_id"
    t.integer  "level_id"
    t.integer  "occupation_id"
    t.integer  "rival_id"
    t.integer  "mate_id"
    t.integer  "favorite_action_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pets", ["occupation_id", "level_rank_count", "status"], :name => "index_pets_on_occupation_id_and_level_rank_count_and_status"
  add_index "pets", ["slug"], :name => "index_pets_on_slug", :unique => true
  add_index "pets", ["user_id", "status"], :name => "index_pets_on_user_id_and_status"

  create_table "rankings", :force => true do |t|
    t.integer  "leaderboard_id", :null => false
    t.datetime "created_at"
  end

  add_index "rankings", ["leaderboard_id", "created_at"], :name => "index_rankings_on_leaderboard_id_and_created_at"

  create_table "ranks", :force => true do |t|
    t.integer "ranking_id",                   :null => false
    t.integer "rankable_id",                  :null => false
    t.string  "rankable_type",                :null => false
    t.integer "rank",          :default => 1, :null => false
    t.integer "score",         :default => 1
  end

  add_index "ranks", ["rankable_id", "rankable_type"], :name => "index_ranks_on_rankable_id_and_rankable_type"
  add_index "ranks", ["ranking_id"], :name => "index_ranks_on_ranking_id"

  create_table "sentients", :force => true do |t|
    t.string  "sentient_type",                                    :null => false
    t.string  "name",                                             :null => false
    t.string  "description",       :limit => 512
    t.integer "health",                           :default => 0,  :null => false
    t.integer "endurance",                        :default => 0,  :null => false
    t.integer "power",                            :default => 0,  :null => false
    t.integer "intelligence",                     :default => 0,  :null => false
    t.integer "fortitude",                        :default => 0,  :null => false
    t.integer "kibble",                           :default => 0,  :null => false
    t.integer "population",                       :default => 0,  :null => false
    t.integer "repopulation_rate",                :default => 1,  :null => false
    t.integer "population_cap",                   :default => 10, :null => false
    t.integer "required_rank",                    :default => 1,  :null => false
  end

  add_index "sentients", ["population", "required_rank"], :name => "index_sentients_on_population_and_required_rank"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shops", :force => true do |t|
    t.integer  "pet_id",                                                 :null => false
    t.integer  "featured_item_id"
    t.string   "name",              :limit => 128,                       :null => false
    t.string   "status",            :limit => 32,  :default => "active", :null => false
    t.string   "specialty",         :limit => 128,                       :null => false
    t.string   "description",       :limit => 512
    t.integer  "inventories_count",                :default => 0,        :null => false
    t.datetime "last_restock_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shops", ["inventories_count", "status"], :name => "index_shops_on_inventories_count_and_status"
  add_index "shops", ["pet_id", "status"], :name => "index_shops_on_pet_id_and_status"
  add_index "shops", ["specialty", "status"], :name => "index_shops_on_specialty_and_status"

  create_table "signs", :force => true do |t|
    t.integer  "sender_id",                  :null => false
    t.integer  "recipient_id",               :null => false
    t.string   "sign_type",    :limit => 32, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "signs", ["sender_id", "recipient_id", "created_at"], :name => "index_signs_on_sender_id_and_recipient_id_and_created_at"
  add_index "signs", ["sign_type", "created_at"], :name => "index_signs_on_sign_type_and_created_at"

  create_table "species", :force => true do |t|
    t.string "name", :limit => 64, :null => false
  end

  create_table "spoils", :force => true do |t|
    t.integer  "pack_id",                                        :null => false
    t.integer  "item_id",                                        :null => false
    t.integer  "pet_id"
    t.string   "status",     :limit => 32, :default => "active", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spoils", ["pack_id", "status"], :name => "index_spoils_on_pack_id_and_status"

  create_table "strategies", :force => true do |t|
    t.integer  "combatant_id",                                       :null => false
    t.string   "combatant_type",                                     :null => false
    t.string   "name",                                               :null => false
    t.string   "status",         :limit => 32, :default => "active", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "strategies", ["combatant_id", "combatant_type", "status"], :name => "index_strategies_on_combatant_id_and_combatant_type_and_status"

  create_table "tames", :force => true do |t|
    t.integer  "pet_id",                                         :null => false
    t.integer  "human_id",                                       :null => false
    t.string   "status",     :limit => 32, :default => "active", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tames", ["pet_id", "human_id", "status"], :name => "index_tames_on_pet_id_and_human_id_and_status"
  add_index "tames", ["status"], :name => "index_tames_on_status"

  create_table "users", :force => true do |t|
    t.integer  "pet_id"
    t.integer  "referer_id"
    t.integer  "facebook_id",          :limit => 8
    t.string   "iphone_udid",          :limit => 512
    t.string   "username",             :limit => 128
    t.string   "first_name",           :limit => 128
    t.string   "last_name",            :limit => 128
    t.string   "email",                :limit => 512
    t.string   "gender",               :limit => 32
    t.string   "facebook_session_key"
    t.string   "persistence_token"
    t.string   "timezone",             :limit => 32,  :default => "UTC +00:00"
    t.string   "locale",               :limit => 16,  :default => "en_US"
    t.string   "role",                 :limit => 128, :default => "member"
    t.datetime "birthday"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.datetime "last_request_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["current_login_at"], :name => "index_users_on_current_login_at"
  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"
  add_index "users", ["iphone_udid"], :name => "index_users_on_iphone_udid"

end
