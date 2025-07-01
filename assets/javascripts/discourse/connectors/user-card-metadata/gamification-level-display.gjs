import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import { computed } from "@ember/object";
import { i18n } from "discourse-i18n";
import GamificationScore from "../../components/gamification-score";

@tagName("div")
@classNames("user-card-metadata-outlet", "gamification-score")
export default class GamificationLevelDisplay extends Component {
  @computed("user.gamification_level_info")
  get levelBarStyle() {
    const info = this.user?.gamification_level_info;
    if (!info) return "width: 0%";
    return `width: ${info.progress_percent}%; background: #f8c100;`;
  }

  <template>
    {{#if this.user.gamification_score}}
      <div class="gamification-meta-box">
        <div class="gamification-score-line">
          <span class="desc">{{i18n "gamification.score"}}:</span>
          <span><GamificationScore @model={{this.user}} /></span>
        </div>

        {{#if this.user.gamification_level_info}}
          <div class="user-level-bar">
            <div class="level-label">
              LV.{{this.user.gamification_level_info.level}} {{this.user.gamification_level_info.name}}
            </div>
            <div class="level-bar-outer">
              <div class="level-bar-inner" style={{this.levelBarStyle}}></div>
            </div>
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
