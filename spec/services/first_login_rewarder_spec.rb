# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscourseGamification::FirstLoginRewarder do
  fab!(:user)

  before { SiteSetting.discourse_gamification_enabled = true }

  it 'creates event and updates score only once per day' do
    freeze_time Date.today
    described_class.new(user).call

    event = DiscourseGamification::GamificationScoreEvent.find_by(user_id: user.id, description: 'first_login')
    expect(event).to be_present
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(10)

    described_class.new(user).call
    expect(DiscourseGamification::GamificationScoreEvent.where(user_id: user.id, description: 'first_login').count).to eq(1)
    expect(DiscourseGamification::GamificationScore.find_by(user_id: user.id).score).to eq(10)
  end
end
