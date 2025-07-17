# frozen_string_literal: true

# name: dk-gamification
# about: Allows admins to create and customize community scoring contests for user accomplishments with leaderboards.
# meta_topic_id: 225916
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/dk-gamification
# required_version: 2.7.0

enabled_site_setting :dk_gamification_enabled

register_asset "stylesheets/common/leaderboard.scss"
register_asset "stylesheets/desktop/leaderboard.scss", :desktop
register_asset "stylesheets/mobile/leaderboard.scss", :mobile
register_asset "stylesheets/common/leaderboard-info-modal.scss"
register_asset "stylesheets/common/leaderboard-minimal.scss"
register_asset "stylesheets/common/leaderboard-admin.scss"
register_asset "stylesheets/common/gamification-score.scss"
register_asset "stylesheets/common/gamification-level.scss"

register_svg_icon "crown"
register_svg_icon "award"

module ::DKGamification
  PLUGIN_NAME = "dk-gamification"

  def self.category_allowed?(category_id, category_list)
    list = category_list.to_s.split("|").map(&:to_i)
    list.empty? || list.include?(category_id)
  end
end

require_relative "lib/dk_gamification/engine"

after_initialize do
  # route: /admin/plugins/dk-gamification
  add_admin_route(
    "gamification.admin.title",
    "dk-gamification",
    { use_new_show_route: true },
  )

  require_relative "jobs/scheduled/update_scores_for_ten_days"
  require_relative "jobs/scheduled/update_scores_for_today"
  require_relative "jobs/regular/recalculate_scores"
  require_relative "jobs/regular/generate_leaderboard_positions"
  require_relative "jobs/regular/refresh_leaderboard_positions"
  require_relative "jobs/regular/delete_leaderboard_positions"
  require_relative "jobs/regular/update_stale_leaderboard_positions"
  require_relative "jobs/regular/regenerate_leaderboard_positions"
  require_relative "lib/dk_gamification/directory_integration"
  require_relative "lib/dk_gamification/guardian_extension"
  require_relative "lib/dk_gamification/scorables/scorable"
  require_relative "lib/dk_gamification/scorables/day_visited"
  require_relative "lib/dk_gamification/scorables/flag_created"
  require_relative "lib/dk_gamification/scorables/like_given"
  require_relative "lib/dk_gamification/scorables/like_received"
  require_relative "lib/dk_gamification/scorables/post_created"
  require_relative "lib/dk_gamification/scorables/first_reply_of_day"
  require_relative "lib/dk_gamification/scorables/post_read"
  require_relative "lib/dk_gamification/scorables/solutions"
  require_relative "lib/dk_gamification/scorables/solution_topic"
  require_relative "lib/dk_gamification/scorables/time_read"
  require_relative "lib/dk_gamification/scorables/topic_created"
  require_relative "lib/dk_gamification/scorables/user_invited"
  require_relative "lib/dk_gamification/user_extension"
  require_relative "lib/dk_gamification/scorables/reaction_given"
  require_relative "lib/dk_gamification/scorables/reaction_received"
  require_relative "lib/dk_gamification/scorables/chat_reaction_given"
  require_relative "lib/dk_gamification/scorables/chat_reaction_received"
  require_relative "lib/dk_gamification/scorables/chat_message_created"
  require_relative "lib/dk_gamification/recalculate_scores_rate_limiter"
  require_relative "lib/dk_gamification/leaderboard_cached_view"
  require_relative "lib/dk_gamification/first_login_rewarder"
  require_relative "lib/dk_gamification/user_level_serializer_extension"

  require_dependency 'dk_gamification/level_helper'

  begin
    DKGamification::UserLevelSerializerExtension.register!
  rescue => e
    Rails.logger.error("Gamification Serializer Registration Error: #{e.message}")
  end

  reloadable_patch do |plugin|
    User.prepend(DKGamification::UserExtension)
    Guardian.include(DKGamification::GuardianExtension)
  end

  if respond_to?(:add_directory_column)
    add_directory_column(
      "gamification_score",
      query: DKGamification::DirectoryIntegration.query,
    )
  end

  add_to_serializer(
    :admin_plugin,
    :extras,
    include_condition: -> { self.name == "dk-gamification" },
  ) do
    {
      gamification_recalculate_scores_remaining:
        DKGamification::RecalculateScoresRateLimiter.remaining,
      gamification_groups:
        Group
          .includes(:flair_upload)
          .all
          .map { |group| BasicGroupSerializer.new(group, root: false, scope: self.scope).as_json },
      gamification_leaderboards:
        DKGamification::GamificationLeaderboard.all.map do |leaderboard|
          LeaderboardSerializer.new(leaderboard, root: false).as_json
        end,
    }
  end

  add_to_serializer(:user_card, :gamification_score) { object.gamification_score }

  add_to_serializer(:site, :default_gamification_leaderboard_id) do
    DKGamification::GamificationLeaderboard.first&.id
  end

  # 1. 기본 유저 serializer 확장 (Post)
  add_to_serializer(:basic_user, :gamification_level_info, include_condition: -> { true }) do
    begin
      id =
        if object.respond_to?(:id)
          object.id
        elsif object.is_a?(Hash)
          if object[:user].respond_to?(:id)
            object[:user].id
          elsif object["user"].respond_to?(:id)
            object["user"].id
          else
            object[:id] || object["id"]
          end
        end
  
      Rails.logger.warn("[🎯 basic_user] extracted id: #{id}")
      Rails.logger.warn("[🎯 basic_user] object=#{object.inspect}")
  
      if id
        Rails.logger.warn("[🎯 basic_user] id 존재함: #{id}")
        progress = DKGamification::LevelHelper.progress_for(id)
        Rails.logger.warn("[🎯 basic_user] progress=#{progress.inspect}")
        progress
      else
        Rails.logger.warn("[🎯 basic_user] id XXX: #{object.inspect}")
        nil
      end
    rescue => e
      Rails.logger.error("Gamification Level Error (basic_user): #{e.message}")
      nil
    end
  end

  add_to_serializer(:post, :gamification_level_info, include_condition: -> { true }) do
    begin
      id = object.user&.id
      if id
        Rails.logger.warn("[💚 post] id 존재함: #{id}")
        DKGamification::LevelHelper.progress_for(id)
      else
        nil
      end
    rescue => e
      Rails.logger.error("Gamification Level Error (post): #{e.message}")
      nil
    end
  end
    
  # 🎯 basic_user serializer에 속성 목록을 명시적으로 추가한다
  # add_to_serializer(:basic_user, :attributes) do
  #   (defined?(super) ? Array(super) : []) + [:gamification_level_info]
  # end
  

  # 2. 현재 로그인한 사용자 serializer 확장
  add_to_serializer(:user, :gamification_level_info, include_condition: -> { true }) do
    begin
      DKGamification::LevelHelper.progress_for(object.id)
    rescue => e
      Rails.logger.error("Gamification Level Error (:user): #{e.message}")
      nil
    end
  end

  # Use the default PostSerializer user serialization which now includes the
  # gamification_level_info via the BasicUser serializer extension.
  
  
  



  add_to_serializer(:user_card, :gamification_level_info) do
    begin
      DKGamification::LevelHelper.progress_for(object.id)
    rescue => e
      Rails.logger.error("Gamification Level Error (:user_card): #{e.message}")
      nil
    end
  end
  
  SeedFu.fixture_paths << Rails
    .root
    .join("plugins", "dk-gamification", "db", "fixtures")
    .to_s

  on(:site_setting_changed) do |name|
    next if name != :score_ranking_strategy

    Jobs.enqueue(::Jobs::RegenerateLeaderboardPositions)
  end

  on(:merging_users) do |source_user, target_user|
    DKGamification::GamificationScore.merge_scores(source_user, target_user)
  end

  on(:user_logged_in) do |user|
    DKGamification::FirstLoginRewarder.new(user).call
  end

  on(:post_created) do |post, opts, user|
    next if post.post_type != Post.types[:regular]
    next if post.hidden? || post.wiki || post.deleted_at

    category_id = post.topic.category_id

    if post.post_number == 1
      if DKGamification::TopicCreated.enabled? &&
           DKGamification.category_allowed?(category_id, SiteSetting.post_created_event_categories)
        DKGamification::GamificationScoreEvent.record!(
          user_id: user.id,
          date: post.created_at.to_date,
          points: SiteSetting.topic_created_score_value,
          reason: "topic_created",
          description: "게시물게시",
          related_id: post.topic_id,
          related_type: "topic",
        )
      end
    else
      if SiteSetting.score_first_reply_of_day_enabled
        already_exists = DKGamification::GamificationScoreEvent.exists?(
          user_id: user.id,
          date: post.created_at.to_date,
          reason: "daily_first_reply"
        )

        if !already_exists
          DKGamification::GamificationScoreEvent.record!(
            user_id: user.id,
            date: post.created_at.to_date,
            points: SiteSetting.first_reply_of_day_score_value,
            reason: "daily_first_reply",
            description: "댓글",
            related_id: post.id,
            related_type: "reply"
          )
        end
      end
    end

    if post.post_number == 1 &&
         SiteSetting.post_created_event_score_value.to_i > 0 &&
         DKGamification.category_allowed?(category_id, SiteSetting.post_created_event_categories)
      DKGamification::GamificationScoreEvent.record!(
        user_id: user.id,
        date: post.created_at.to_date,
        points: SiteSetting.post_created_event_score_value,
        reason: "post_created",
        description: "게시물게시",
        related_id: post.topic_id,
        related_type: "topic",
      )
    end
  end
  

  on(:post_action_created) do |post_action|
    next unless post_action.post_action_type_id == PostActionType.types[:like]

    if DKGamification::LikeGiven.enabled?
      DKGamification::GamificationScoreEvent.record!(
        user_id: post_action.user_id,
        date: post_action.created_at.to_date,
        points: DKGamification::LikeGiven.score_multiplier,
        reason: "like_given"
      )
    end

    if DKGamification::LikeReceived.enabled?
      DKGamification::GamificationScoreEvent.record!(
        user_id: post_action.post.user_id,
        date: post_action.created_at.to_date,
        points: DKGamification::LikeReceived.score_multiplier,
        reason: "like_received"
      )
    end
  end

  on(:post_action_destroyed) do |post_action, undone|
    next unless post_action.post_action_type_id == PostActionType.types[:like]

    if DKGamification::LikeGiven.enabled?
      DKGamification::GamificationScoreEvent.record!(
        user_id: post_action.user_id,
        date: post_action.created_at.to_date,
        points: -DKGamification::LikeGiven.score_multiplier,
        reason: "like_removed"
      )
    end

    if DKGamification::LikeReceived.enabled?
      DKGamification::GamificationScoreEvent.record!(
        user_id: post_action.post.user_id,
        date: post_action.created_at.to_date,
        points: -DKGamification::LikeReceived.score_multiplier,
        reason: "like_removed"
      )
    end
  end

  on(:accepted_solution) do |post|
    category_id = post.topic.category_id

    if SiteSetting.accepted_solution_event_score_value.to_i > 0 &&
         DKGamification.category_allowed?(category_id, SiteSetting.accepted_solution_event_categories)
      DKGamification::GamificationScoreEvent.record!(
        user_id: post.user_id,
        date: Time.zone.now.to_date,
        points: SiteSetting.accepted_solution_event_score_value,
        reason: "accepted_solution",
        description: "솔루션 채택 / 포인트 회수",
        related_id: post.topic_id,
        related_type: "topic",
      )
    end

    if SiteSetting.accepted_solution_topic_event_score_value.to_i > 0 &&
         DKGamification.category_allowed?(category_id, SiteSetting.accepted_solution_topic_event_categories)
      DKGamification::GamificationScoreEvent.record!(
        user_id: post.topic.user_id,
        date: Time.zone.now.to_date,
        points: SiteSetting.accepted_solution_topic_event_score_value,
        reason: "accepted_solution_topic",
        description: "솔루션 채택 / 작성자에게 포인트 부여",
        related_id: post.topic_id,
        related_type: "topic",
      )
    end
  end

  on(:unaccepted_solution) do |post|
    category_id = post.topic.category_id

    if SiteSetting.accepted_solution_event_score_value.to_i > 0 &&
         DKGamification.category_allowed?(category_id, SiteSetting.accepted_solution_event_categories)
      DKGamification::GamificationScoreEvent.record!(
        user_id: post.user_id,
        date: Time.zone.now.to_date,
        points: -SiteSetting.accepted_solution_event_score_value,
        reason: "accepted_solution_removed",
        description: "솔루션 채택 취소 / 포인트 회수",
        related_id: post.topic_id,
        related_type: "topic",
      )
    end

    if SiteSetting.accepted_solution_topic_event_score_value.to_i > 0 &&
         DKGamification.category_allowed?(category_id, SiteSetting.accepted_solution_topic_event_categories)
      DKGamification::GamificationScoreEvent.record!(
        user_id: post.topic.user_id,
        date: Time.zone.now.to_date,
        points: -SiteSetting.accepted_solution_topic_event_score_value,
        reason: "accepted_solution_topic_removed",
        description: "솔루션 채택 취소 / 작성자에게 포인트 회수",
        related_id: post.topic_id,
        related_type: "topic",
      )
    end
  end
end
