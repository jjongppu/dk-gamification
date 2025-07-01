import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import { computed } from "@ember/object";
import { hbs } from "ember-cli-htmlbars";
import { i18n } from "discourse-i18n";
import GamificationScore from "../../components/gamification-score";

@tagName("div")
@classNames("user-card-metadata-outlet", "gamification-score")
export default class GamificationScoreConnector extends Component {
  @computed("user.gamification_level_info")
  get level_bar_style() {
    const info = this.user?.gamification_level_info;
    if (!info) return "width: 0%";
    return `width: ${info.exp_percent}%; background: #f8c100`;
  }

  static template = hbs`
    {{#if this.user.gamification_score}}
      <span class="desc">{{i18n "gamification.score"}} </span>
      <span><GamificationScore @model={{this.user}} /></span>
    {{/if}}

    test

    {{#if this.user.gamification_level_info}}
      <div class="user-level-bar">
        <div class="level-label">
          LV.{{this.user.gamification_level_info.level}} {{this.user.gamification_level_info.name}}
        </div>
        <div class="level-bar-outer">
          <div class="level-bar-inner" style={{this.level_bar_style}}></div>
        </div>
      </div>
    {{/if}}
  `;
}
