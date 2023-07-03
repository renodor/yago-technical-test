# frozen_string_literal: true

module InsuranceApi
  module V1
    class Client
      BASE_URL = 'https://staging-gtw.seraphin.be/quotes'
      API_KEY  = Rails.application.credentials.insurance_api_key

      class ApiError < StandardError; end

      def initialize
        @connection = Faraday.new(url: BASE_URL, headers: { 'X-Api-Key' => API_KEY }) do |conn|
          conn.adapter Faraday.default_adapter # The default adapter is :net_http
          conn.request :json
          conn.response :json
        end
      end

      def professional_liability(body:)
        post_request(endpoint: 'professional-liability', body: formated_body(body))
      end

      private

      def post_request(endpoint:, body:)
        handle_response @connection.post(endpoint, body)
      end

      def handle_response(response)
        response_body = response.body
        return { success: true, payload: formated_response(response_body['data']) } if response_body['success']
        return { success: false, payload: response_body.dig('data', 'message') } if response.success?

        # If this happens we should probably report and log this error somewhere
        raise ApiError, "#{response.status}: #{response.body}"
      end

      def formated_body(body)
        {
          annualRevenue: body[:annual_revenue].to_i,
          enterpriseNumber: body[:enterprise_number],
          legalName: body[:legal_name],
          naturalPerson: body[:person_type] == 'natural_person',
          nacebelCodes: body[:nacebel_codes],
          coverageCeilingFormula: body[:coverage_ceiling_formula],
          deductibleFormula: body[:deductible_formula]
        }
      end

      def formated_response(response)
        {
          coverage_ceiling: response['coverageCeiling'],
          deductible: response['deductible'],
          covers: {
            after_delivery: response.dig('grossPremiums', 'afterDelivery'),
            public_liability: response.dig('grossPremiums', 'publicLiability'),
            professional_indemnity: response.dig('grossPremiums', 'professionalIndemnity'),
            entrusted_objects: response.dig('grossPremiums', 'entrustedObjects'),
            legal_expenses: response.dig('grossPremiums', 'legalExpenses')
          }
        }
      end
    end
  end
end
