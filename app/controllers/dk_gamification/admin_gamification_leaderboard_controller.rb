# frozen_string_literal: true

module DkGamification
  class AdminGamificationLeaderboardController < ::ApplicationController
    def index
      render json: { leaderboard: [] }
    end
  end
end
