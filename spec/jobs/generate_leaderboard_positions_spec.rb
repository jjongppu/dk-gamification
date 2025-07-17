# frozen_string_literal: true

require "rails_helper"

describe Jobs::GenerateLeaderboardPositions do
  fab!(:leaderboard) { Fabricate(:gamification_leaderboard) }
  fab!(:score) { Fabricate(:gamification_score, user_id: leaderboard.created_by_id) }
  let(:leaderboard_positions) { DKGamification::LeaderboardCachedView.new(leaderboard) }

  it "generates leaderboard positions" do
    expect { leaderboard_positions.scores }.to raise_error(
      DKGamification::LeaderboardCachedView::NotReadyError,
    )

    described_class.new.execute(leaderboard_id: leaderboard.id)

    expect(leaderboard_positions.scores.length).to eq(1)
  end
end
