# frozen_string_literal: true

module DKGamification
  class GamificationScore < ActiveRecord::Base
    self.table_name = "gamification_scores"

    belongs_to :user
  end
end
