FactoryBot.define do
  factory :employee do
    sequence(:name)       { |n| "Employee #{n}" }
    sequence(:email)      { |n| "employee#{n}@example.com" }
    department            { "Engineering" }
    base_salary           { 50_000 }
    active                { true }
  end
end