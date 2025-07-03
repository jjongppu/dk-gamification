import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "add-user-level-info-widget",

  initialize() {
    withPluginApi("0.8.25", (api) => {
      api.decorateWidget("poster-name:before", (helper) => {
        const user = helper.attrs.user;
        const levelInfo = user?.gamification_level_info;
        console.log('gamification_level_info user image ::::');
        if (!levelInfo) return;

        const image = helper.h("img", {
          src: levelInfo.image_url,
          style: "width: 24px; height: 24px; margin-right: 2px;"
        });

        // const text = helper.h("span", {
        //   style: "color: #f8c100;"
        // }, `${levelInfo.name} LV.${levelInfo.level} ${Math.floor(levelInfo.progress_percent)}%`);

        return helper.h("span", { style: " margin-right: 2px !important;" }, [image]);
      });
    });
  }
};
