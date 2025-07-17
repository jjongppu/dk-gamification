# frozen_string_literal: true

module ::DKGamification
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DKGamification
  end
end
