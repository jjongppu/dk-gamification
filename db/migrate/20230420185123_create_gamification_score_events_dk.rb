# frozen_string_literal: true
class CreateGamificationScoreEventsDk < ActiveRecord::Migration[7.0]
  def change
    create_table :gamification_score_events, if_not_exists: true do |t|
      t.integer :user_id, null: false
      t.date :date, null: false
      t.integer :points, null: false
      t.text :description, null: true

      t.timestamps
    end

    unless index_exists?(:gamification_score_events, [:user_id, :date])
      add_index :gamification_score_events, [:user_id, :date]
    end

    unless index_exists?(:gamification_score_events, :date)
      add_index :gamification_score_events, :date
    end
  end
end
