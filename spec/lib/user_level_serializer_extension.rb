# plugin.rb 안에 또는 별도 확장파일에서
add_to_serializer(:basic_user, :user_level_image_url, false) do
  level = DiscourseGamification::GamificationLevelInfo.find_by(user_id: object.id)
  level&.image_url
end