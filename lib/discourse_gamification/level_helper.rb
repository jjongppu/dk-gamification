# frozen_string_literal: true

module DiscourseGamification
    class LevelHelper

      # plugins/discourse-gamification/lib/discourse_gamification/level_helper.rb

      def self.progress_for(user_id)
        level = get_level(user_id) # 너가 사용하는 레벨 계산 메서드
        {
          level: level,
          name: level_name(level),
          progress: calculate_progress(user_id),
          image_url: "https://your-cdn.com/level_icons/level_#{level}.png"
        }
      end

      def self.progress_for(user_id)
        score = GamificationScore.find_by(user_id: user_id)&.score || 0
        level_info = GamificationLevelInfo.where(":score BETWEEN min_score AND max_score", score: score).first
  
        return {
          level: nil, progress_percent: 0, current_score: score,
          min: 0, max: 0, name: nil, image_url: nil
        } unless level_info
  
        min = level_info.min_score
        max = level_info.max_score
        progress = ((score - min).to_f / (max - min) * 100).round
  
        {
          level: level_info.level,
          progress_percent: progress,
          current_score: score,
          min: min,
          max: max,
          name: level_info.name,
          image_url: level_info.image_url
        }
      end
    end
  end
  