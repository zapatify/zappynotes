ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |name, start, finish, request_id, payload|
  req = payload[:request]
  Rails.logger.warn "[Rack::Attack] Throttled: #{req.ip} - #{req.path} (#{payload[:matched]})"
end

ActiveSupport::Notifications.subscribe('blocklist.rack_attack') do |name, start, finish, request_id, payload|
  req = payload[:request]
  Rails.logger.warn "[Rack::Attack] Blocked: #{req.ip} - #{req.path}"
end