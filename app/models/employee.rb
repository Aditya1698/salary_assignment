class Employee < ApplicationRecord
  has_many :salary_records, dependent: :destroy

  validates :name,        presence: true
  validates :email,       presence: true, uniqueness: { case_sensitive: false }
  validates :department,  presence: true
  validates :base_salary, presence: true, numericality: { greater_than: 0 }
  validates :active,      inclusion: { in: [true, false] }

  scope :active,        -> { where(active: true) }
  scope :by_department, ->(dept) { where(department: dept) }

  def full_info
    "#{name} - #{department}"
  end

  def apply_raise!(percentage)
    raise ArgumentError, "Percentage must be positive" unless percentage.positive?

    self.base_salary = (base_salary * (1 + percentage.to_f / 100)).round(2)
    save!

    salary_records.create!(
      base_salary: base_salary,
      bonus:       0,
      deductions:  0,
      month:       Date.today.month,
      year:        Date.today.year
    )
  end
end