# frozen_string_literal: true

module DiscourseGamification
  module UserLevelSerializerExtension
    def self.register!
      add_to_serializer(:user_card, :gamification_level_info) do
        begin
          DiscourseGamification::LevelHelper.progress_for(object.id)
        rescue => e
          Rails.logger.error("Gamification Level Error: #{e.message}")
          nil
        end
      end

      add_to_serializer(:post, :gamification_level_info) do
        begin
          DiscourseGamification::LevelHelper.progress_for(object.user_id)
        rescue => e
          Rails.logger.error("Gamification Level Error: #{e.message}")
          nil
        end
      end
    end
  end
end
