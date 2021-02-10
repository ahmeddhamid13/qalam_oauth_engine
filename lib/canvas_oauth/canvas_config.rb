require 'colorize'
module CanvasOauth
  module CanvasConfig
    mattr_accessor :key, :secret

    def self.load_config
      YAML::load(File.open(config_file))[Rails.env]
    end

    def self.config_file
      CanvasOauth.app_root.join('config/canvas.yml')
    end

    def self.setup!
      if File.exists?(config_file)
        Rails.logger.info "Initializing Canvas using configuration in #{config_file}"
        config = load_config
        self.key = config['key']
        self.secret = config['secret']

        Rails.logger.info "\n> Initializing Key #{config['key']} - Secret #{config['secret']}\n".green

      elsif ENV['CANVAS_KEY'].present? && ENV['CANVAS_SECRET'].present?
        Rails.logger.info "Initializing Canvas using environment vars CANVAS_KEY and CANVAS_SECRET"
        self.key = ENV['CANVAS_KEY']
        self.secret = ENV['CANVAS_SECRET']

        Rails.logger.info "\n> Initializing Key #{ENV['CANVAS_KEY']} - Secret #{ENV['CANVAS_SECRET']}\n".green
      else
        warn "Warning: Canvas key and secret not configured (RAILS_ENV = #{ENV['RAILS_ENV']})."
      end
    end
  end
end
