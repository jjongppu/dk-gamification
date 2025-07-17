import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "dk-gamification-admin-plugin-configuration-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser || !currentUser.admin) {
      return;
    }

    withPluginApi("1.1.0", (api) => {
      api.addAdminPluginConfigurationNav("dk-gamification", [
        {
          label: "gamification.leaderboard.title",
          route: "adminPlugins.show.dk-gamification-leaderboards",
        },
      ]);
    });
  },
};
