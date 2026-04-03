FactoryBot.define do
  factory :employee do
    name        { Faker::Name.full_name }
    email       { Faker::Internet.unique.email }
    department  { %w[Engineering HR Finance Marketing].sample }
    base_salary { Faker::Number.between(from: 25_000, to: 2_00_000) }
    active      { true }
  end
end