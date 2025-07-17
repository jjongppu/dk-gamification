# frozen_string_literal: true

module DkGamification
  class GamificationScore < ActiveRecord::Base
    self.table_name = "gamification_scores"

    belongs_to :user

    def self.adjust_score(user_id:, points:)
      DB.exec(<<~SQL, user_id: user_id, points: points)
        INSERT INTO gamification_scores (user_id, score, date)
        VALUES (:user_id, :points, CURRENT_DATE)
        ON CONFLICT (user_id) DO UPDATE
        SET score = gamification_scores.score + EXCLUDED.score;
      SQL
    end
  end
end
