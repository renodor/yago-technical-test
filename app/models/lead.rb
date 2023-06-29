# frozen_string_literal:true

class Lead < ApplicationRecord
  has_many :quotes, dependent: :destroy

  validates :email, :phone_number, presence: true
  validates :email, format: { with: /.+@.+\..+/ }
end
