class SalaryCalculatorService
  class DuplicatePayslipError < StandardError; end

  PF_CEILING = 15_000
  PF_RATE    = 0.12

  TAX_SLABS = [
    { min: 0,        max: 3_00_000,        rate: 0.00 },
    { min: 3_00_000, max: 6_00_000,        rate: 0.05 },
    { min: 6_00_000, max: 9_00_000,        rate: 0.10 },
    { min: 9_00_000, max: Float::INFINITY, rate: 0.20 }
  ].freeze

  def initialize(employee)
    @employee = employee
  end

  def calculate_tax
    annual_salary = @employee.base_salary * 12
    annual_tax    = 0.0

    TAX_SLABS.each do |slab|
      break if annual_salary <= slab[:min]
      taxable_in_slab = [annual_salary, slab[:max]].min - slab[:min]
      annual_tax += taxable_in_slab * slab[:rate]
    end

    (annual_tax / 12).round(2)
  end

  def calculate_pf
    pf_base = [@employee.base_salary, PF_CEILING].min
    (pf_base * PF_RATE).round(2)
  end

  def total_deductions
    calculate_tax + calculate_pf
  end

  def generate_payslip(month:, year:, bonus: 0)
    if @employee.salary_records.exists?(month: month, year: year)
      raise DuplicatePayslipError, "A payslip for #{Date::MONTHNAMES[month]} #{year} already exists."
    end

    @employee.salary_records.create!(
      base_salary: @employee.base_salary,
      bonus:       bonus,
      deductions:  total_deductions,
      month:       month,
      year:        year
    )
  end

  def annual_summary(year)
    records = @employee.salary_records.where(year: year)

    {
      total_gross:      records.sum { |r| r.gross_salary },
      total_deductions: records.sum(&:deductions),
      total_net:        records.sum { |r| r.net_salary },
      months_paid:      records.count
    }
  end
end