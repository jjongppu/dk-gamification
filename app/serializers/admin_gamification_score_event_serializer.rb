# frozen_string_literal: true

class AdminGamificationScoreEventSerializer < ApplicationSerializer
  attributes :id, :user_id, :date, :points, :reason, :description, :related_id, :related_type, :created_at, :updated_at
end
