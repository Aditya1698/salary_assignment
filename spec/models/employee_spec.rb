require "rails_helper"

RSpec.describe Employee, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:department) }
    it { should validate_presence_of(:base_salary) }
    it { should validate_numericality_of(:base_salary).is_greater_than(0) }
  end

  describe "associations" do
    it { should have_many(:salary_records).dependent(:destroy) }
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:employee)).to be_valid
    end
  end

  describe "scopes" do
    describe ".by_department" do
      it "returns employees filtered by department" do
        eng = create(:employee, department: "Engineering")
        _hr = create(:employee, department: "HR")
        expect(Employee.by_department("Engineering")).to contain_exactly(eng)
      end
    end

    describe ".active" do
      it "returns only active employees" do
        active   = create(:employee, active: true)
        inactive = create(:employee, active: false)
        expect(Employee.active).to include(active)
        expect(Employee.active).not_to include(inactive)
      end
    end
  end

  describe "#full_info" do
    it "returns name and department together" do
      employee = build(:employee, name: "Alice Smith", department: "Engineering")
      expect(employee.full_info).to eq("Alice Smith - Engineering")
    end
  end

  describe "#apply_raise!" do
    let(:employee) { create(:employee, base_salary: 50_000) }

    it "increases the base salary by the given percentage" do
      employee.apply_raise!(10)
      expect(employee.reload.base_salary).to eq(55_000)
    end

    it "raises an error when percentage is zero or negative" do
      expect { employee.apply_raise!(0) }.to raise_error(ArgumentError, /must be positive/)
      expect { employee.apply_raise!(-5) }.to raise_error(ArgumentError, /must be positive/)
    end

    it "records the salary change in salary_records" do
      expect { employee.apply_raise!(10) }.to change { employee.salary_records.count }.by(1)
    end
  end
end