# frozen_string_literal: true

module Jobs
  class RecalculateScores < ::Jobs::Base
    def execute(args)
      user_id = args[:user_id]
      raise Discourse::InvalidParameters.new(:user_id) if user_id.blank?

      DKGamification::GamificationScore.calculate_scores(
        since_date: args[:since] || 10.days.ago,
      )

      ::MessageBus.publish "/recalculate_scores",
                           {
                             success: true,
                             remaining:
                               DKGamification::RecalculateScoresRateLimiter.remaining,
                             user_id: [user_id],
                           }
    end
  end
end
