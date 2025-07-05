module DiscourseGamification
  class FirstLoginRewarder
    POINTS = 10
    DESCRIPTION = "first_login"

    def initialize(user)
      @user = user
    end

    def call
      return unless SiteSetting.discourse_gamification_enabled
      return if SiteSetting.score_day_visited_enabled

      today = Date.current
      return if GamificationScoreEvent.exists?(user_id: @user.id, date: today, description: DESCRIPTION)

      GamificationScoreEvent.create!(
        user_id: @user.id,
        date: today,
        points: POINTS,
        description: DESCRIPTION,
        reason: DESCRIPTION,
      )
    end
  end
end
