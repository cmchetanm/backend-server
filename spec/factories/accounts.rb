FactoryBot.define do
  factory :account do
    auth_id { Faker::Alphanumeric.unique.alphanumeric(number: 10, min_alpha: 6, min_numeric: 4) }
    username { Faker::Name.first_name }
  end
end
