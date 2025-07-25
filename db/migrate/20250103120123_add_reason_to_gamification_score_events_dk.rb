# frozen_string_literal: true
class AddReasonToGamificationScoreEventsDk < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:gamification_score_events, :reason)
      add_column :gamification_score_events, :reason, :string, default: "", null: true

      execute <<~SQL
        UPDATE gamification_score_events
        SET reason = ''
        WHERE reason IS NULL
      SQL

      change_column_null :gamification_score_events, :reason, false
    end
  end

  def down
    if column_exists?(:gamification_score_events, :reason)
      remove_column :gamification_score_events, :reason
    end
  end
end
