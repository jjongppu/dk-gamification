import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "add-user-level-info-widget",

  initialize() {
    withPluginApi("0.8.25", (api) => {
      api.decorateWidget("poster-name:before", (helper) => {
        // const user = helper.attrs.user;
        const levelInfo = helper.getModel().gamification_level_info; // post에 직접 포함된 속성으로 변경됨!

        console.log('1.helper.attrs ::::', helper.attrs);
        console.log('2.gamification_level_info::::', levelInfo);
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
