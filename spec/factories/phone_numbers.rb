FactoryBot.define do
  factory :phone_number do
    number { Faker::Number.unique.number(digits: 10).to_s }
    association :account
  end
end
