module CanvasOauth
  class CanvasApiExtensions
    def self.build(canvas_url, user_id, tool_consumer_instance_guid)
      token = CanvasOauth::Authorization.fetch_token(user_id, tool_consumer_instance_guid)
      refresh_token = CanvasOauth::Authorization.fetch_refresh_token(user_id, tool_consumer_instance_guid)
      CanvasApi.new(canvas_url, token, refresh_token, CanvasConfig.key, CanvasConfig.secret)
    end
  end
end
