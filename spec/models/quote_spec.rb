# frozen_string_literal:true

require 'rails_helper'

RSpec.describe Quote do
  it { is_expected.to belong_to(:lead) }

  it { is_expected.to validate_presence_of(:annual_revenue) }
  it { is_expected.to validate_presence_of(:enterprise_number) }
  it { is_expected.to validate_presence_of(:person_type) }
  it { is_expected.to validate_presence_of(:deductible) }
  it { is_expected.to validate_presence_of(:coverage_ceiling) }
  it { is_expected.to validate_presence_of(:covers) }
  it { is_expected.to validate_length_of(:enterprise_number).is_equal_to(10) }

  it { is_expected.to define_enum_for(:person_type).with_values({ natural_person: 0, legal_person: 1 }) }

  it 'validates that all covers belong to available covers' do
    quote = build(:quote, covers: { after_delivery: 10.15, legal_expenses: 20.30 })
    quote2 = build(:quote, covers: { legal_expenses: 10, bad_cover: 20 })

    expect(quote.valid?).to be true

    expect(quote2.valid?).to be false
    expect(quote2.errors.full_messages).to eq(['Covers should all be part of available covers'])
  end
end
