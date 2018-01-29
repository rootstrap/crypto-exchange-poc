require 'net/http'

module Coingate
  class Client
    ENVIRONMENTS = {
      'live' => 'https://api.coingate.com',
      'sandbox' => 'https://api-sandbox.coingate.com'
    }.freeze

    attr_reader :base_url

    # options:
    #   String :environment ('sandbox')
    #     - One of: 'sandbox', 'live'
    #   String :app_id
    #   String :api_key
    #   String :api_secret
    def initialize(options)
      @options = options
      @base_url = URI(ENVIRONMENTS.fetch(options[:environment]))
    end

    def execute(*args) # TODO
      api_request(*args)
      #request('id' => 'jsonrpc', 'method' => command, 'params' => args)
    end

    private

    def api_request(path, request_method = :post, params = {})
      case request_method
      when :get
        request_get(path)
      when :post
        request_post(path, params)
      end
    end

    def request_get(path, headers)
      request = Net::HTTP::Get.new("/v1/#{path}")

      perform_request(request)
    end

    def request_post(path, params)
      request = Net::HTTP::Post.new("/v1/#{path}")

      request.set_form_data(params)
      request['Content-Type'] = 'application/x-www-form-urlencoded'

      perform_request(request)
    end

    def set_request_headers(request)
      nonce     = (Time.now.to_f * 1e6).to_i
      message   = nonce.to_s + @options[:app_id] + @options[:api_key]
      signature = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        @options[:api_secret],
        message
      )

      request['Access-Nonce'] = nonce
      request['Access-Key'] = @options[:api_key]
      request['Access-Signature'] = signature
    end

    def perform_request(request)
      set_request_headers(request)

      http = Net::HTTP.new(base_url.hostname, base_url.port)
      http.use_ssl = true
      response = http.request(request)

      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        body = response.body
        JSON.parse(body) unless body.empty?
      else
        p response
      end
    end
  end
end
