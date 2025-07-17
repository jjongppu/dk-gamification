# frozen_string_literal: true

module ::DKGamification
  module UserExtension
    DEFAULT_SCORE = 0

    def gamification_score
      return DEFAULT_SCORE if !default_leaderboard

      DKGamification::GamificationLeaderboard.find_position_by(
        leaderboard_id: default_leaderboard.id,
        period: "all_time",
        for_user_id: self.id,
      )&.total_score || DEFAULT_SCORE
    rescue DKGamification::LeaderboardCachedView::NotReadyError
      Jobs.enqueue(Jobs::GenerateLeaderboardPositions, leaderboard_id: default_leaderboard.id)

      DEFAULT_SCORE
    end

    def default_leaderboard
      @default_leaderboard ||= DKGamification::GamificationLeaderboard.select(:id).first
    end
  end
end
