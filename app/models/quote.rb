# frozen_string_literal:true

class Quote < ApplicationRecord
  belongs_to :lead

  validates :annual_revenue, :enterprise_number, :legal_name, :nacebel_codes, presence: true
  validates :enterprise_number, length: { is: 10 }
  validate :nacebel_codes, :nacebel_codes_length

  private

  def nacebel_codes_length
    errors.add(:nacebel_codes, 'should all be 5 characters') unless nacebel_codes.all? { |nacebel_code| nacebel_code.length == 5 }
  end
end
