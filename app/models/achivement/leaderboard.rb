require 'active_support/core_ext/string/inflections'

class Leaderboard < ActiveRecord::Base
  RANKING_PERIOD_DAYS = 14
  SQL_RECENT = "created_at >= DATE_ADD(NOW(), INTERVAL -#{RANKING_PERIOD_DAYS} DAY)"
  
  has_many :rankings, :order => 'rankings.created_at DESC'
  has_many :awards, :order => 'rank ASC'
  
  validates_presence_of :rankable_type, :name, :ranked_count
  validates_inclusion_of :rankable_type, :in => %w(Pet Pack Shop)
  
  named_scope :include_awards
  named_scope :board, lambda { |b| 
    { :conditions => ["leaderboards.name = ?", b], :limit => 1 }
  }
  
  class << self
    def create_rankings
      Leaderboard.all.each do |lb|
        rank_leaderboard lb
      end
      ActivityStream.log! 'world', 'leaderboards'      
    end
    
    def rank_leaderboard(leaderboard)
      ranking = leaderboard.rankings.build
      
      rankables = self.send leaderboard.rankable_method_from_name.to_sym
      rankables.each_with_index do |r,idx|
        rank = idx + 1
        ranking.ranks.build(:rankable => r, :rank => rank)
      end
      return ranking.save
    end
    
    def rankables_for_forerunners
      leaderboard = Leaderboard.board('Forerunners').first
      return Pet.all(:order => "pets.experience DESC",
                     :joins => "INNER JOIN users ON users.id = pets.user_id " +
                               "AND users.last_login_at >= DATE_ADD(NOW(), INTERVAL -#{RANKING_PERIOD_DAYS} DAY)")
    end
    
    def rankables_for_relentless
      leaderboard = Leaderboard.board('Strongest Fighters').first
      sql_joins = "INNER JOIN challenges ON pets.id IN (attacker_id, defender_id)"
      sql_order = "COUNT(challenges.id) DESC"
      sql_group = "pets.id"
      return Pet.all(:conditions => "challenges.#{Leaderboard::SQL_RECENT} AND challenges.status = 'resolved' ", 
                     :joins => sql_joins, 
                     :order => sql_order,
                     :group => sql_group,
                     :limit => leaderboard.ranked_count)
    end
    
    def rankables_for_manlords
      leaderboard = Leaderboard.board('Manlords').first
      sql_joins = "INNER JOIN users ON users.id = pets.user_id " +
                  "AND users.last_login_at >= DATE_ADD(NOW(), INTERVAL -#{RANKING_PERIOD_DAYS} DAY) " +
                  "INNER JOIN tames ON pets.id = tames.pet_id"
      sql_group = "pets.id"
      sql_order = "(SELECT SUM(humans.power) FROM humans JOIN tames ON humans.id = tames.human_id WHERE tames.pet_id = pets.id AND tames.status = 'kenneled') + " +
                  "(SELECT COUNT(tames.id) FROM tames WHERE tames.pet_id = pets.id AND tames.status = 'kenneled' ) DESC"
      return Pet.all(:joins => sql_joins, 
                     :order => sql_order,
                     :group => sql_group,
                     :limit => leaderboard.ranked_count)
    end
    
    def rankables_for_ambassadors
      leaderboard = Leaderboard.board('Ambassadors').first
      sql_group = "pets.id"
      sql_order = "(COUNT(signs.id) * #{AppConfig.leaderboards.ambassadors.signs}) + " +
                  "(COUNT(messages.id) * #{AppConfig.leaderboards.ambassadors.messages}) + " +
                  "(COUNT(forum_posts.id) * #{AppConfig.leaderboards.ambassadors.forum_posts}) DESC "
      sql_joins = "INNER JOIN users ON users.id = pets.user_id AND users.last_login_at >= DATE_ADD(NOW(), INTERVAL -#{RANKING_PERIOD_DAYS} DAY) " +
                  "LEFT JOIN signs ON pets.id = signs.sender_id AND signs.#{Leaderboard::SQL_RECENT} " +            
                  "LEFT JOIN messages ON pets.id = messages.sender_id AND messages.#{Leaderboard::SQL_RECENT} " +
                  "LEFT JOIN forum_posts ON forum_posts.user_id = users.id"
      return Pet.all(:joins => sql_joins, 
                     :order => sql_order,
                     :group => sql_group,
                     :limit => leaderboard.ranked_count)
    end
    
    def rankables_for_franchises
      leaderboard = Leaderboard.board('Franchises').first
      sql_group = "shops.id"
      sql_joins = "INNER JOIN activity_streams ON shops.id = activity_streams.indirect_object_id " +
                  "AND activity_streams.indirect_object_type = 'Shop' " +
                  "AND activity_streams.created_at >= DATE_ADD(NOW(), INTERVAL -#{RANKING_PERIOD_DAYS} DAY) "
      sql_order = "COUNT(activity_streams.id) DESC "
      return Shop.all(:joins => sql_joins, 
                     :order => sql_order,
                     :group => sql_group,
                     :limit => leaderboard.ranked_count)      
    end
    
    def rankables_for_hordes
      leaderboard = Leaderboard.board('Hordes').first
      sql_cols  = "packs.* "
      sql_joins = "INNER JOIN pack_members ON packs.id = pack_members.pack_id " +
                  "INNER JOIN items AS standard ON standard.id = packs.standard_id "
                  "INNER JOIN pets ON pets.id = pack_members.pet_id " +
                  "INNER JOIN users ON pets.user_id = users.id AND users.last_login_at >= DATE_ADD(NOW(), INTERVAL -7 DAY) " +
                  "LEFT JOIN spoils ON packs.id = spoils.pack_id " +
                  "LEFT JOIN items ON items.id = spoils.item_id " +
      sql_group = "packs.id"
      sql_order = "(COUNT(pack_members.id) * #{AppConfig.leaderboards.hordes.members}) + " +
                  "(standard.power * #{AppConfig.leaderboards.hordes.standard_power}) + " +
                  "(packs.kibble * #{AppConfig.leaderboards.hordes.treasury}) + " +                  
                  "(1 * #{AppConfig.leaderboards.hordes.spoils}) DESC "
      return Pack.all(:joins => sql_joins, 
                     :select => sql_cols,
                     :order => sql_order,
                     :group => sql_group,
                     :limit => leaderboard.ranked_count)
    end
    
    def rankables_for_strongest
      leaderboard = Leaderboard.board('Strongest Fighters').first
      avg_number_fights = connection.select_value "SELECT AVG(cnt) FROM ( " + 
                                                  "SELECT COUNT(challenges.id) AS cnt  " +
                                                  "FROM challenges " +
                                                  "INNER JOIN pets ON pets.id = attacker_id OR pets.id = defender_id " +
                                                  "WHERE challenges.status = 'resolved' " +
                                                  "AND challenges.#{SQL_RECENT} ) tbl"
      
      avg_number_wins = connection.select_value "SELECT AVG(cnt) FROM ( " +
                                                "SELECT COUNT(battles.id) AS cnt " +
                                                "FROM battles JOIN pets ON pets.id = battles.winner_id " +
                                                "WHERE pets.status = 'active' " +
                                                "AND battles.#{SQL_RECENT} ) tbl"

      sql_joins = "INNER JOIN challenges ON pets.id IN (attacker_id, defender_id)"                                                    
      pet_number_wins = "SELECT COUNT(battles.id) FROM battles WHERE battles.winner_id = pets.id AND battles.#{SQL_RECENT}"
      pet_number_fights = "COUNT(challenges.id)"
      sql_group = "pets.id"
      br_sql = "((#{avg_number_wins}) * (#{avg_number_fights}) + (#{pet_number_wins}) * (#{pet_number_fights})) / (#{avg_number_fights}) * (#{pet_number_fights})"
      return Pet.all(:conditions => "challenges.#{Leaderboard::SQL_RECENT} AND challenges.status = 'resolved' ", 
                     :joins => sql_joins, 
                     :order => br_sql,
                     :group => sql_group,
                     :limit => leaderboard.ranked_count)
    end
  end    
    
  def rankable_method_from_name
    normal = self.name.split(' ').first.downcase
    return "rankables_for_#{normal}"
  end
end