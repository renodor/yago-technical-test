# frozen_string_literal:true

require 'rails_helper'

RSpec.describe Lead do
  it { is_expected.to have_many(:quotes).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:phone_number) }
  it { is_expected.to validate_presence_of(:nacebel_codes) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:activity) }
  it { is_expected.to allow_value('test@test.com').for(:email) }
  it { is_expected.not_to allow_value('test@test').for(:email) }
  it { is_expected.not_to allow_value('test.com').for(:email) }

  it { is_expected.to define_enum_for(:status).with_values(initial: 0, quoted: 2, contacted: 3, customer: 4, closed: 5) }
  it { is_expected.to define_enum_for(:activity).with_values(medical: 0) }

  it 'validates that all NACEBEL-CODES have 5 characters' do
    lead = build(:lead, nacebel_codes: %w[12345 12345])
    lead2 = build(:lead, nacebel_codes: %w[12345 1234])

    expect(lead.valid?).to be true
    expect(lead2.valid?).to be false

    expect(lead2.errors.full_messages).to eq(['Nacebel codes should all be 5 characters'])
  end

  it 'sets activity before validation' do
    lead = build(:lead, nacebel_codes: ['86230'], activity: nil)

    expect(lead.activity).to be_nil
    lead.valid?
    expect(lead.activity).to eq('medical')
  end

  describe '#recommended_covers' do
    let(:lead) { create(:lead, activity: :medical) }

    it 'returns recommended covers regarding lead activity' do
      expect(lead.recommended_covers).to eq(['legal_expenses'])
    end
  end

  describe '#recommended_deductible_formula' do
    let(:lead) { create(:lead, activity: :medical) }

    it 'returns recommended deductible formula regarding lead activity' do
      expect(lead.recommended_deductible_formula).to eq('small')
    end
  end

  describe '#recommended_coverage_ceiling_formula' do
    let(:lead) { create(:lead, activity: :medical) }

    it 'returns recommended coverage ceiling formula regarding lead activity' do
      expect(lead.recommended_coverage_ceiling_formula).to eq('large')
    end
  end
end
