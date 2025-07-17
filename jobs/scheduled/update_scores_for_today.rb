# frozen_string_literal: true

module Jobs
  class UpdateScoresForToday < ::Jobs::Scheduled
    every 1.hour

    def execute(args = nil)
      DKGamification::GamificationScore.calculate_scores

      DKGamification::LeaderboardCachedView.purge_all_stale
      DKGamification::LeaderboardCachedView.refresh_all
      DKGamification::LeaderboardCachedView.create_all
    end
  end
end
