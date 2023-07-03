# frozen_string_literal:true

FactoryBot.define do
  factory :lead do
    email { 'test@email.com' }
    phone_number { '+32 4 10 10 10 10' }
    first_name { 'Cool' }
    last_name { 'User' }
    address { '1 Rue de là-bas' }
    zip_code { '12345'}
    city { 'Bruxelles' }
    nacebel_codes { %w[86210 86230] }
    activity { 'medical' }
  end
end
