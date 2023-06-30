# frozen_string_literal:true

class Quote < ApplicationRecord
  belongs_to :lead

  validates :annual_revenue, :enterprise_number, :legal_name, :nacebel_codes, presence: true
  validates :enterprise_number, length: { is: 10 }
  validate :nacebel_codes, :nacebel_codes_length

  enum coverage_ceiling_formula: {
    small: 0,
    medium: 1,
    large: 2
  }, _prefix: true

  enum deducible_formula: {
    small: 0,
    medium: 1,
    large: 2
  }, _prefix: true

  # TODO: maybe change natural_person boolean to an enum to easily display the 2 options

  MEDICAL_NACEBEL_CODES = {
    'general practice doctor' => 86210,
    'specialist doctor' => 86220,
    'dentist' => 86230
  }.freeze

  COVERS = %w[after_delivery public_liability professional_indemnity entrusted_objects legal_expenses].freeze

  private

  def nacebel_codes_length
    errors.add(:nacebel_codes, 'should all be 5 characters') unless nacebel_codes.all? { |nacebel_code| nacebel_code.length == 5 }
  end
end
