# frozen_string_literal: true
class AddReasonToGamificationScoreEvents < ActiveRecord::Migration[7.0]
  def up
    add_column :gamification_score_events, :reason, :string, default: "", null: true
    execute <<~SQL
      UPDATE gamification_score_events
      SET reason = ''
      WHERE reason IS NULL
    SQL
    change_column_null :gamification_score_events, :reason, false
  end

  def down
    remove_column :gamification_score_events, :reason
  end
end
