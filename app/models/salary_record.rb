class SalaryRecord < ApplicationRecord
  belongs_to :employee

  validates :base_salary, presence: true, numericality: { greater_than: 0 }
  validates :bonus,       numericality: { greater_than_or_equal_to: 0 }
  validates :deductions,  numericality: { greater_than_or_equal_to: 0 }
  validates :month,       presence: true,
                          numericality: { only_integer: true,
                                         greater_than_or_equal_to: 1,
                                         less_than_or_equal_to: 12 }
  validates :year,        presence: true,
                          numericality: { only_integer: true, greater_than: 2000 }

  validates :month, uniqueness: {
    scope: %i[employee_id year],
    message: "already has a salary record for this period"
  }

  def gross_salary
    base_salary + bonus
  end

  def net_salary
    [gross_salary - deductions, 0].max
  end

  def period_label
    Date.new(year, month, 1).strftime("%B %Y")
  end
end