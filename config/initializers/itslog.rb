Itslog.configure do |config|
    config.namespace_colors = {
      'action_controller' => "\e[32m",
      'active_record'     => "\e[94m",
      'mongo'             => "\e[94m",
      'action_view'       => "\e[36m"
    }
    config.format = "%t [%n]: %m"
end