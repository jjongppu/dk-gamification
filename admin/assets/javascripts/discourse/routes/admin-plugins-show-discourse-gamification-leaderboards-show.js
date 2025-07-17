import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";
import GamificationLeaderboard from "discourse/plugins/dk-gamification/discourse/models/gamification-leaderboard";

export default class DKGamificationLeaderboardShow extends DiscourseRoute {
  @service adminPluginNavManager;

  model(params) {
    const leaderboardsData = this.modelFor(
      "adminPlugins.show.dk-gamification-leaderboards"
    );
    const id = parseInt(params.id, 10);

    const leaderboard = leaderboardsData.leaderboards.findBy("id", id);
    if (leaderboard) {
      return leaderboard;
    }

    return ajax(
      `/admin/plugins/dk-gamification/leaderboards/${id}`
    ).then((response) => GamificationLeaderboard.create(response.leaderboard));
  }
}
