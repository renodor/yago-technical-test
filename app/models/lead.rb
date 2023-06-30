# frozen_string_literal:true

class Lead < ApplicationRecord
  has_many :quotes, dependent: :destroy

  validates :email, :phone_number, :status, presence: true
  validates :email, format: { with: /.+@.+\..+/ }

  # I'm not sure what are the different status we should use here,
  # but the idea is just to be able to follow the commercial journey of a lead.
  # At some point it could even be useful to have a proper state machines, using a gem like https://github.com/aasm/aasm,
  # in order to know exactly when a lead evolved from one status to another.
  enum status: {
    initial: 0,
    contacted: 1,
    customer: 2,
    closed: 3
  }
end
