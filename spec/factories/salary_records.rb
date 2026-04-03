FactoryBot.define do
  factory :salary_record do
    association :employee
    base_salary { Faker::Number.between(from: 25_000, to: 2_00_000) }
    bonus       { 0 }
    deductions  { 0 }
    month       { Faker::Number.between(from: 1, to: 12) }
    year        { 2025 }
  end
end