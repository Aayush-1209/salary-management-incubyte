require 'rails_helper'

RSpec.describe Employee, type: :model do
  # ── Validations ───────────────────────────────────────────────────────────
  describe 'validations' do
    subject { build(:employee) }

    it { is_expected.to validate_presence_of(:employee_number) }
    it { is_expected.to validate_uniqueness_of(:employee_number).case_insensitive }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('jane@acme.com').for(:email) }
    it { is_expected.not_to allow_value('not-an-email').for(:email) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:department) }
    it { is_expected.to validate_presence_of(:job_title) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:hired_on) }

    it { is_expected.to validate_inclusion_of(:level).in_array(Employee::LEVELS).allow_nil }
    it { is_expected.to validate_inclusion_of(:currency).in_array(Employee::CURRENCIES) }
  end

  # ── Associations ──────────────────────────────────────────────────────────
  describe 'associations' do
    it { is_expected.to have_many(:salary_histories).dependent(:destroy) }
  end

  # ── Scopes ────────────────────────────────────────────────────────────────
  describe 'scopes' do
    describe '.active' do
      it 'returns only active employees' do
        active = create(:employee, active: true)
        _inactive = create(:employee, :inactive)

        expect(Employee.active).to contain_exactly(active)
      end
    end

    describe '.by_country' do
      it 'returns employees in the given country' do
        india = create(:employee, country: 'India')
        _usa  = create(:employee, country: 'United States')

        expect(Employee.by_country('India')).to contain_exactly(india)
      end
    end

    describe '.by_department' do
      it 'returns employees in the given department' do
        eng   = create(:employee, department: 'Engineering')
        _hr   = create(:employee, department: 'Human Resources')

        expect(Employee.by_department('Engineering')).to contain_exactly(eng)
      end
    end
  end

  # ── Instance methods ──────────────────────────────────────────────────────
  describe '#full_name' do
    it 'returns first and last name joined' do
      employee = build(:employee, first_name: 'Jane', last_name: 'Doe')
      expect(employee.full_name).to eq('Jane Doe')
    end
  end

  describe '#current_salary' do
    it 'returns the most recent salary history entry' do
      employee = create(:employee)
      old_salary = create(:salary_history, employee: employee, effective_date: 1.year.ago.to_date, gross_salary: 60_000)
      new_salary = create(:salary_history, employee: employee, effective_date: 1.month.ago.to_date, gross_salary: 75_000)

      expect(employee.current_salary).to eq(new_salary)
    end

    it 'returns nil when the employee has no salary history' do
      employee = create(:employee)
      expect(employee.current_salary).to be_nil
    end
  end
end
