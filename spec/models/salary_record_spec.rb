require "rails_helper"

RSpec.describe SalaryRecord, type: :model do
  describe "validations" do
    it { should validate_presence_of(:base_salary) }
    it { should validate_numericality_of(:base_salary).is_greater_than(0) }
    it { should validate_numericality_of(:bonus).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:deductions).is_greater_than_or_equal_to(0) }

    it "validates uniqueness of month+year per employee" do
      employee = create(:employee)
      create(:salary_record, employee: employee, month: 4, year: 2025)
      duplicate = build(:salary_record, employee: employee, month: 4, year: 2025)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:month]).to include("already has a salary record for this period")
    end
  end

  describe "associations" do
    it { should belong_to(:employee) }
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:salary_record)).to be_valid
    end
  end

  describe "#gross_salary" do
    it "returns base_salary plus bonus" do
      record = build(:salary_record, base_salary: 50_000, bonus: 5_000)
      expect(record.gross_salary).to eq(55_000)
    end
  end

  describe "#net_salary" do
    it "returns gross salary minus deductions" do
      record = build(:salary_record, base_salary: 50_000, bonus: 5_000, deductions: 8_000)
      expect(record.net_salary).to eq(47_000)
    end

    it "is never negative" do
      record = build(:salary_record, base_salary: 1_000, bonus: 0, deductions: 99_999)
      expect(record.net_salary).to eq(0)
    end
  end

  describe "#period_label" do
    it "returns a human-readable month/year string" do
      record = build(:salary_record, month: 4, year: 2025)
      expect(record.period_label).to eq("April 2025")
    end
  end
end