# frozen_string_literal: true

module ::DkGamification
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DkGamification
  end
end
