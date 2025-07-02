# frozen_string_literal: true

module DiscourseGamification
  module UserLevelSerializerExtension
    def self.register!
      ::UserCardSerializer.class_eval do
        attributes :gamification_level_info

        def gamification_level_info
          begin
            DiscourseGamification::LevelHelper.progress_for(object.id)
          rescue => e
            Rails.logger.error("Gamification Level Error: #{e.message}")
            nil
          end
        end
      end

      ::PostSerializer.class_eval do
        attributes :gamification_level_info

        def gamification_level_info
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
end
