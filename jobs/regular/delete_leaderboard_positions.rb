# frozen_string_literal: true

module Jobs
  class DeleteLeaderboardPositions < ::Jobs::Base
    def execute(args)
      leaderboard_id = args[:leaderboard_id]
      raise Discourse::InvalidParameters.new(:leaderboard_id) if leaderboard_id.blank?

      leaderboard =
        DKGamification::GamificationLeaderboard.find_by(id: leaderboard_id) ||
          DKGamification::DeletedGamificationLeaderboard.new(leaderboard_id)

      DKGamification::LeaderboardCachedView.new(leaderboard).delete
    end
  end
end
