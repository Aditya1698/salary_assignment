FactoryBot.define do
  factory :salary_record do
    association :employee
    base_salary { 50_000 }
    bonus       { 0 }
    deductions  { 0 }
    sequence(:month) { |n| (n % 12) + 1 }
    year        { 2025 }
  end
end