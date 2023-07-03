# frozen_string_literal:true

FactoryBot.define do
  factory :quote do
    annual_revenue { 30_000 }
    enterprise_number { '1234567890' }
    legal_name { 'Cool Company' }
    person_type { :natural_person }
    coverage_ceiling { 800_000 }
    deductible { 10_000 }
    covers do
      {
        after_delivery: 10.15,
        legal_expenses: 20.30
      }
    end

    lead
  end
end
