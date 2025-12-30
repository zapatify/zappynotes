class Rack::Attack
  # Always allow requests from localhost
  # safelist('allow-localhost') do |req|
  #   req.ip == '127.0.0.1' || req.ip == '::1'
  # end

  # Limit sign-in attempts per IP
  throttle("sign-in/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/sign_in" && req.post?
      req.ip
    end
  end

  # Limit sign-up attempts per IP
  throttle("sign-up/ip", limit: 3, period: 1.hour) do |req|
    if req.path == "/sign_up" && req.post?
      req.ip
    end
  end

  # Limit API requests per IP (general)
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Limit notebook creation
  throttle("notebooks/create/ip", limit: 20, period: 1.hour) do |req|
    if req.path == "/notebooks" && req.post?
      req.ip
    end
  end

  # Limit note creation
  throttle("notes/create/ip", limit: 100, period: 1.hour) do |req|
    if req.path =~ /\/notebooks\/\d+\/notes/ && req.post?
      req.ip
    end
  end

  ### Custom Blocklist ###

  # Block specific IPs (you can add IPs here manually)
  blocklist("block-bad-ips") do |req|
    # Add malicious IPs to this array
    blocked_ips = [
      # '192.168.1.100',
      # '10.0.0.50',
    ]

    blocked_ips.include?(req.ip)
  end

  # Block IPs stored in environment variable (for production)
  blocklist("block-env-ips") do |req|
    blocked_ips = ENV["BLOCKED_IPS"].to_s.split(",").map(&:strip)
    blocked_ips.include?(req.ip)
  end

  ### Response to Throttled Requests ###

  self.throttled_responder = lambda do |request|
    [
      429,
      { "Content-Type" => "text/html" },
      [ <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>Rate Limit Exceeded</title>
          <style>
            body { font-family: 'Work Sans', Arial, sans-serif; text-align: center; padding: 50px; background: #f9fafb; }
            .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
            h1 { color: #ea580c; font-size: 32px; margin-bottom: 20px; }
            p { color: #666; font-size: 18px; line-height: 1.6; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>Rate Limit Exceeded</h1>
            <p>You've made too many sign-in attempts.</p>
            <p>Please wait a moment and try again.</p>
          </div>
        </body>
        </html>
      HTML
      ]
    ]
  end

  ### Response to Blocked Requests ###

  self.blocklisted_responder = lambda do |env|
    [ 403, { "Content-Type" => "text/html" }, [ '
      <!DOCTYPE html>
      <html>
      <head>
        <title>Access Denied</title>
        <style>
          body { font-family: "Work Sans", Arial, sans-serif; text-align: center; padding: 50px; }
          h1 { color: #dc2626; }
          p { color: #666; font-size: 18px; }
        </style>
      </head>
      <body>
        <h1>Access Denied</h1>
        <p>Your IP address has been blocked.</p>
      </body>
      </html>
    ' ] ]
  end
end

# # Enable Rack::Attack
# Rack::Attack.enabled = true

# Use Rails' built-in cache store
Rack::Attack.cache.store = Rails.cache
