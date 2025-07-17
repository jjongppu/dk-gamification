# frozen_string_literal: true
class CreateGamificationScoreTableDk < ActiveRecord::Migration[6.1]
  def change
    create_table :gamification_scores, if_not_exists: true do |t|
      t.integer :user_id, null: false
      t.date :date, null: false
      t.integer :score, null: false
    end

    unless index_exists?(:gamification_scores, [:user_id, :date], unique: true)
      add_index :gamification_scores, [:user_id, :date], unique: true
    end

    unless index_exists?(:gamification_scores, :date)
      add_index :gamification_scores, :date
    end
  end
end
