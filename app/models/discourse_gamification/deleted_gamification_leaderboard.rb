# frozen_string_literal: true

module ::DKGamification
  class DeletedGamificationLeaderboard
    attr_reader :id

    def initialize(id)
      @id = id
    end
  end
end
