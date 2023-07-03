# frozen_string_literal:true

class Lead < ApplicationRecord
  has_many :quotes, dependent: :destroy

  validates :email, :phone_number, :nacebel_codes, :status, :activity, presence: true
  validates :email, format: { with: /.+@.+\..+/ }
  validate :nacebel_codes, :nacebel_codes_length

  before_validation :set_activity

  # I'm not sure what are the different status we should use here,
  # but the idea is just to be able to follow the commercial journey of a lead.
  # At some point it could even be useful to have a proper state machines, using a gem like https://github.com/aasm/aasm,
  # in order to know exactly when a lead evolved from one status to another.
  enum status: {
    initial: 0,
    quoted: 2,
    contacted: 3,
    customer: 4,
    closed: 5
  }

  enum activity: {
    medical: 0
  }

  MEDICAL_NACEBEL_CODES = {
    'general practice doctor' => '86210',
    'specialist doctor' => '86220',
    'dentist' => '86230'
  }.freeze

  def recommended_covers
    Quote::COVERS_BY_ACTIVITY[activity.to_sym]
  end

  def recommended_deductible_formula
    Quote::DEDUCTIBLE_FORMULA_BY_ACTIVITY[activity.to_sym]
  end

  def recommended_coverage_ceiling
    Quote::COVERAGE_CEILING_FORMULA_BY_ACTIVITY[activity.to_sym]
  end

  private

  def nacebel_codes_length
    errors.add(:nacebel_codes, 'should all be 5 characters') unless nacebel_codes.all? { |nacebel_code| nacebel_code.length == 5 }
  end

  def set_activity
    # This looks weird right now because we only have one type of activity,
    # but the purpose of this callback is to set the lead activity depending on its NACEBEL-CODES,
    # in order to later on be able to recommend different types of covers and deducible and coverage ceiling formulas
    self.activity = :medical if nacebel_codes.intersect?(MEDICAL_NACEBEL_CODES.values)
  end
end
