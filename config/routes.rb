# frozen_string_literal: true

Discourse::Application.routes.draw do
  scope '/admin/plugins/dk-gamification', constraints: StaffConstraint.new do
    get '/score_events' => 'dk_gamification/admin_gamification_score_event#show'
    post '/score_events' => 'dk_gamification/admin_gamification_score_event#create'
    put '/score_events' => 'dk_gamification/admin_gamification_score_event#update'
  end

  post '/gamification/check-in' => 'dk_gamification/check_ins#create'
end
