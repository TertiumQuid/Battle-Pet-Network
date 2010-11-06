class Facebook::LeaderboardsController < Facebook::FacebookController
  def index
    @leaderboards = Leaderboard.include_awards.all
  end
end