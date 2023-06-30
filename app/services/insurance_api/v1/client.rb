# frozen_string_literal: true

module InsuranceApi
  module V1
    class Client
      BASE_URL = 'https://staging-gtw.seraphin.be/quotes'
      API_KEY  = Rails.application.credentials.insurance_api_key

      def initialize
        @connection = Faraday.new(url: BASE_URL, headers: { 'X-Api-Key' => API_KEY }) do |conn|
          conn.adapter Faraday.default_adapter # The default adapter is :net_http
          conn.request :json
          conn.response :json
        end
      end

      def professional_liability(body:)
        post_request(endpoint: 'professional-liability', body: body.transform_keys { |key| key.camelize(:lower) })
      end

      private

      def post_request(endpoint:, body:)
        handle_response @connection.post(endpoint, body)
      end

      def handle_response(response)
        response_body = response.body
        return response_body['data'].deep_transform_keys(&:underscore) if response.success? && response_body['success']

        response_status = response.status
        raise Error.new(
          "#{response_status} Error",
          response_status,
          response_body.presence || {}
        )
      end

      class Error < StandardError
        attr_reader :status, :body

        def initialize(error_message, status, body)
          @status = status
          @body = body
          super(error_message)
        end
      end
    end
  end
end
