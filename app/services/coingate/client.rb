require './lib/coingate/client'

module Services
  module Coingate
    class Client
      CG_ENVIRONMENT = ENV.fetch('CG_ENVIRONMENT')
      CG_APP_ID = ENV.fetch('CG_APP_ID')
      CG_API_KEY = ENV.fetch('CG_API_KEY')
      CG_API_SECRET = ENV.fetch('CG_API_SECRET')

      def initialize
        @client = ::Coingate::Client.new(
          environment: CG_ENVIRONMENT,
          app_id: CG_APP_ID,
          api_key: CG_API_KEY,
          api_secret: CG_API_SECRET
        )
      end

      def new_address
        @client.execute('/orders', :post, {
          order_id: 'test-2',
          price: 0.00000001,
          currency: 'BTC',
          receive_currency: 'BTC'
        })
      end
    end
  end
end
