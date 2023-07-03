# frozen_string_literal: true

require 'rails_helper'

describe InsuranceApi::V1::Client do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:fake_api_key) { '1234' }
  let(:fake_response_payload) { { 'success' => true, 'data' => {} } }
  let(:stub_response) { [200, {}, fake_response_payload] }

  before do
    stub_const('InsuranceApi::V1::Client::API_KEY', fake_api_key)
    allow(Faraday).to receive(:new).and_return(Faraday.new { |builder| builder.adapter(:test, stubs) })
  end

  describe '#connection' do
    it 'connects to the correct Api url with the correct Api key' do
      stubs.post('professional-liability') { |_env| stub_response }

      described_class.new.professional_liability(body: {})

      expect(Faraday).to have_received(:new).with(
        {
          url: 'https://staging-gtw.seraphin.be/quotes',
          headers: { 'X-Api-Key' => fake_api_key }
        }
      )
    end
  end

  describe '#professional_liability' do
    let(:fake_body) do
      {
        annual_revenue: '80000',
        enterprise_number: '0649885171',
        legal_name: 'Example SA',
        person_type: 'natural_person',
        nacebel_codes: %w[62010 62020],
        coverage_ceiling_formula: 'large',
        deductible_formula: 'small'
      }
    end

    let(:fake_formated_body) do
      {
        annualRevenue: 80_000,
        enterpriseNumber: '0649885171',
        legalName: 'Example SA',
        naturalPerson: true,
        nacebelCodes: %w[62010 62020],
        coverageCeilingFormula: 'large',
        deductibleFormula: 'small'
      }
    end

    it 'sends request to the correct endpoint with the given formated body' do
      stubs.post('professional-liability') do |env|
        expect(env.request_body).to eq(fake_formated_body)
        stub_response
      end

      described_class.new.professional_liability(body: fake_body)
    end
  end

  describe '#handle_response' do
    context 'when request is successful and data is successfuly returned' do
      let(:fake_response_payload) do
        {
          'success' => true,
          'data' => {
            'available' => true,
            'coverageCeiling' => 100_000,
            'deductible' => 5000,
            'quoteId' => '012604234942544',
            'grossPremiums' => {
              'afterDelivery' => 53.00,
              'publicLiability' => 150.00,
              'professionalIndemnity' => 270.00,
              'entrustedObjects' => 12.92,
              'legalExpenses' => 20.87
            }
          }
        }
      end

      let(:fake_formated_response_payload) do
        {
          coverage_ceiling: 100_000,
          deductible: 5000,
          covers: {
            after_delivery: 53.00,
            public_liability: 150.00,
            professional_indemnity: 270.00,
            entrusted_objects: 12.92,
            legal_expenses: 20.87
          }
        }
      end

      it 'returns response formated body data' do
        stubs.post('professional-liability') { |_env| stub_response }

        response = described_class.new.professional_liability(body: {})
        expect(response[:success]).to be true
        expect(response[:payload]).to eq(fake_formated_response_payload)
      end
    end

    context 'when request is successful but data cannot be returned' do
      let(:fake_response_payload) do
        {
          'success' => false,
          'data' => {
            'available' => false,
            'message' => 'Some data error'
          }
        }
      end

      it 'returns error message' do
        stubs.post('professional-liability') { |_env| stub_response }

        response = described_class.new.professional_liability(body: {})
        expect(response[:success]).to be false
        expect(response[:payload]).to eq('Some data error')
      end
    end

    context 'when request is not successful' do
      it 'raises an InsuranceApi::V1::Client::Error' do
        stubs.post('professional-liability') { |_env| [500, {}, 'Some server error'] }

        expect { described_class.new.professional_liability(body: {}) }
          .to raise_error(InsuranceApi::V1::Client::ApiError) do |error|
            expect(error.message).to eq('500: Some server error')
          end
      end
    end
  end
end
