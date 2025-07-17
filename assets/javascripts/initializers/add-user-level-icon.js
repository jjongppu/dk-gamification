import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "add-user-level-info-widget",

  initialize() {
    withPluginApi("0.8.25", (api) => {
      api.decorateWidget("poster-name:before", (helper) => {
        const post = helper.getModel?.() || helper.attrs.post || helper.attrs;
        const levelInfo = post.gamification_level_info;
        if (!levelInfo) return;

        const image = helper.h("img", {
          src: levelInfo.image_url,
          style: "width: 24px; height: 24px; margin-right: 2px;",
        });

        return helper.h("span", { style: "margin-right: 2px" }, [image]);
      });
    });
  },
};
