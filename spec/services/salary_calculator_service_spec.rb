require "rails_helper"

RSpec.describe SalaryCalculatorService do
  let(:employee) { create(:employee, base_salary: 60_000) }
  subject(:service) { described_class.new(employee) }

  describe "#calculate_tax" do
    it "returns zero tax for salary up to 3,00,000 annual" do
      emp = build(:employee, base_salary: 25_000)
      expect(described_class.new(emp).calculate_tax).to eq(0)
    end

    it "applies 5% slab for annual salary between 3L and 6L" do
      emp = build(:employee, base_salary: 40_000) # 4.8L annual
      expect(described_class.new(emp).calculate_tax).to eq(750)
    end

    it "applies 10% slab for annual salary between 6L and 9L" do
      emp = build(:employee, base_salary: 65_000) # 7.8L annual
      expect(described_class.new(emp).calculate_tax).to eq(2_750)
    end

    it "applies 20% slab for annual salary above 9L" do
      emp = build(:employee, base_salary: 1_00_000) # 12L annual
      expect(described_class.new(emp).calculate_tax).to eq(8_750)
    end
  end

  describe "#calculate_pf" do
    it "returns 12% of base salary" do
      expect(service.calculate_pf).to eq(1_800) 
    end

    it "caps PF at statutory ceiling of 15,000" do
      high_earner = build(:employee, base_salary: 2_00_000)
      expect(described_class.new(high_earner).calculate_pf).to eq(1_800)
    end
  end

  describe "#total_deductions" do
    it "returns the sum of tax and PF" do
      allow(service).to receive(:calculate_tax).and_return(2_750)
      allow(service).to receive(:calculate_pf).and_return(7_200)
      expect(service.total_deductions).to eq(9_950)
    end
  end

  describe "#generate_payslip" do
    let(:result) { service.generate_payslip(month: 4, year: 2025, bonus: 5_000) }

    it "returns a SalaryRecord" do
      expect(result).to be_a(SalaryRecord)
    end

    it "persists the salary record" do
      expect { result }.to change(SalaryRecord, :count).by(1)
    end

    it "raises DuplicatePayslipError if record already exists for that period" do
      service.generate_payslip(month: 4, year: 2025)
      expect { service.generate_payslip(month: 4, year: 2025) }
        .to raise_error(SalaryCalculatorService::DuplicatePayslipError)
    end
  end

  describe "#annual_summary" do
    before do
      create(:salary_record, employee: employee, month: 1, year: 2025, base_salary: 60_000, bonus: 0,     deductions: 9_000)
      create(:salary_record, employee: employee, month: 2, year: 2025, base_salary: 60_000, bonus: 5_000, deductions: 9_000)
      create(:salary_record, employee: employee, month: 3, year: 2025, base_salary: 65_000, bonus: 0,     deductions: 9_500)
    end

    let(:summary) { service.annual_summary(2025) }

    it "returns total gross salary" do
      expect(summary[:total_gross]).to be_within(0.01).of(1_90_000)
    end

    it "returns total deductions" do
      expect(summary[:total_deductions]).to eq(27_500)
    end

    it "returns total net salary" do
      expect(summary[:total_net]).to be_within(0.01).of(1_62_500)
    end

    it "returns months paid" do
      expect(summary[:months_paid]).to eq(3)
    end

    it "returns zeros when no records exist for the year" do
      summary = service.annual_summary(2099)
      expect(summary[:total_gross]).to eq(0)
      expect(summary[:months_paid]).to eq(0)
    end
  end
end