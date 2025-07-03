import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "add-user-level-text",

  initialize() {
    withPluginApi("0.8.25", (api) => {
      api.decorateWidget("poster-name:before", (helper) => {
        return helper.h("span", {
          style: "color: red; margin-left: 5px;"
        }, "A");
      });
    });
  }
};
