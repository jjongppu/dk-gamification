import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "add-user-level-icon",

  initialize() {
    withPluginApi("0.8.25", (api) => {
      api.decorateWidget("user-name:before", (dec) => {
        const user = dec.attrs.user;
        console.log(' !!!! user', user);
        const imageUrl = user?.user_level_info?.image_url;

        if (imageUrl) {
          return dec.h("img.user-level-icon", {
            attributes: {
              src: imageUrl,
              style:
                "width: 20px; height: 20px; margin-right: 4px; border-radius: 50%; vertical-align: middle;",
            },
          });
        }
      });
    });
  },
};
