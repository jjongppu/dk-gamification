# frozen_string_literal: true

# name: dk-gamification
# about: Display user level info on user cards and posts
# version: 0.1
# authors: Discourse
# url: https://github.com/discourse/dk-gamification

module ::DKGamification
  PLUGIN_NAME = "dk-gamification"
end

enabled_site_setting :dk_gamification_enabled

register_asset "stylesheets/common/gamification-level.scss"

after_initialize do
  require_relative "lib/dk_gamification/engine"
  require_relative "lib/dk_gamification/level_helper"
  require_relative "lib/dk_gamification/user_level_serializer_extension"

  DKGamification::UserLevelSerializerExtension.register!
end
