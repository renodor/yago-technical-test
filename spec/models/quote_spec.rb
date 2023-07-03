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
end
