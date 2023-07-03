# frozen_string_literal:true

class Quote < ApplicationRecord
  belongs_to :lead

  validates :annual_revenue, :enterprise_number, :legal_name, :deductible, :coverage_ceiling, :covers, presence: true
  validates :enterprise_number, length: { is: 10 }

  # TODO: validate covers.keys include AVAILABLE_COVERS
  # TODO: maybe change natural_person boolean to an enum to easily display the 2 options

  AVAILABLE_COVERS = %w[after_delivery public_liability professional_indemnity entrusted_objects legal_expenses].freeze

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
    medical: 'high'
  }.freeze
end
