export default {
  resource: "admin.adminPlugins.show",

  path: "/plugins",

  map() {
    this.route(
      "dk-gamification-leaderboards",
      { path: "leaderboards" },
      function () {
        this.route("show", { path: "/:id" });
      }
    );
  },
};
