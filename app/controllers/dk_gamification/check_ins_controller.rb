# frozen_string_literal: true
module ::DKGamification
  class DKGamification::CheckInsController < ApplicationController
    requires_plugin DKGamification::PLUGIN_NAME
    before_action :ensure_logged_in

    def create
      unless SiteSetting.score_day_visited_enabled
        render json: { points_awarded: false, points: 0 }
        return
      end

      today = Date.current
      reason = SiteSetting.day_visited_score_reason
      weekend = today.saturday? || today.sunday?
      points = if weekend
        SiteSetting.day_visited_weekend_score_value
      else
        SiteSetting.day_visited_score_value
      end
      description = weekend ? "주말출석" : "출석"

      existing = DKGamification::GamificationScoreEvent.find_by(
        user_id: current_user.id,
        date: today,
        reason: reason,
      )

      if existing
        render json: { points_awarded: false, points: 0 }
      else
        event = DKGamification::GamificationScoreEvent.record!(
          user_id: current_user.id,
          date: today,
          points: points,
          reason: reason,
          description: description,
        )

        render json: { points_awarded: true, points: event.points }
      end
    end
  end
end