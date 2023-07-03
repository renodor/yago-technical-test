# frozen_string_literal:true

class Lead < ApplicationRecord
  has_many :quotes, dependent: :destroy

  validates :email, :phone_number, :nacebel_codes, :status, :activity, presence: true
  validates :email, format: { with: /.+@.+\..+/ }
  validate :nacebel_codes, :validate_nacebel_codes_length

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

  # Used to define Lead activity. We are currently dealing with 1 activity (medical) so a simple array is enough,
  # but this would need more complexe logic, with more NACE-BEL codes and more activities
  MEDICAL_NACEBEL_CODES = %w[86210 86220 86230].freeze

  # Currently the only NACE-BEL codes we support
  PROFESSION_BY_NACEBEL_CODE = {
    '86210' => 'General practice doctor',
    '86220' => 'Specialist doctor',
    '86230' => 'Dentist'
  }.freeze

  def recommended_covers
    Quote::COVERS_BY_ACTIVITY[activity.to_sym]
  end

  def recommended_deductible_formula
    Quote::DEDUCTIBLE_FORMULA_BY_ACTIVITY[activity.to_sym]
  end

  def recommended_coverage_ceiling_formula
    Quote::COVERAGE_CEILING_FORMULA_BY_ACTIVITY[activity.to_sym]
  end

  private

  def validate_nacebel_codes_length
    errors.add(:nacebel_codes, 'should all be 5 characters') unless nacebel_codes&.all? { |nacebel_code| nacebel_code.length == 5 }
  end

  def set_activity
    # This looks weird right now because we only have one type of activity,
    # but the purpose of this callback is to set the lead activity depending on its NACE-BEL codes,
    # in order to later be able to recommend different types of covers and deductible and coverage ceiling formulas
    self.activity = :medical if nacebel_codes&.intersect?(MEDICAL_NACEBEL_CODES)
  end
end
