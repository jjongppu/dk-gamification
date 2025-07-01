import Component from "@ember/component";
import { computed } from "@ember/object";

export default Component.extend({
  level_bar_style: computed("user.gamification_score", "user.gamification_level_info", function () {
    const info = this.user.gamification_level_info;
    if (!info) return "width: 0%";
    return `width: ${info.progress_percent}%; background: #f8c100`;
  }),
});
