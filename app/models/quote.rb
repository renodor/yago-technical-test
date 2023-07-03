# frozen_string_literal:true

class Quote < ApplicationRecord
  belongs_to :lead

  validates :annual_revenue, :enterprise_number, :person_type, :deductible, :coverage_ceiling, :covers, presence: true
  validates :enterprise_number, length: { is: 10 }

  enum person_type: {
    natural_person: 0,
    legal_person: 1
  }

  # TODO: validate covers.keys include AVAILABLE_COVERS

  AVAILABLE_COVERS = %w[after_delivery public_liability legal_expenses professional_indemnity entrusted_objects].freeze

  # Used to advice what is the best cover for lead
  COVERS_BY_ACTIVITY = {
    medical: ['legal_expenses']
  }.freeze

  # Used to advice what is the best deductible formula for lead
  DEDUCTIBLE_FORMULA_BY_ACTIVITY = {
    medical: 'small'
  }.freeze

  # Used to advice what is the best coverage ceiling formula for lead
  COVERAGE_CEILING_FORMULA_BY_ACTIVITY = {
    medical: 'large'
  }.freeze
end
