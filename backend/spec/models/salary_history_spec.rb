require 'rails_helper'

RSpec.describe SalaryHistory, type: :model do
  # ── Validations ───────────────────────────────────────────────────────────
  describe 'validations' do
    subject { build(:salary_history) }

    it { is_expected.to validate_presence_of(:gross_salary) }
    it { is_expected.to validate_numericality_of(:gross_salary).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:effective_date) }
    it { is_expected.to validate_inclusion_of(:reason).in_array(SalaryHistory::REASONS).allow_nil }
  end

  # ── Associations ──────────────────────────────────────────────────────────
  describe 'associations' do
    it { is_expected.to belong_to(:employee) }
  end

  # ── Scopes ────────────────────────────────────────────────────────────────
  describe 'scopes' do
    describe '.chronological' do
      it 'returns salary history ordered by effective_date descending' do
        employee = create(:employee)
        older = create(:salary_history, employee: employee, effective_date: 1.year.ago.to_date)
        newer = create(:salary_history, employee: employee, effective_date: 1.month.ago.to_date)

        expect(SalaryHistory.chronological).to eq([newer, older])
      end
    end

    describe '.as_of' do
      it 'returns only entries on or before the given date' do
        employee = create(:employee)
        past   = create(:salary_history, employee: employee, effective_date: 2.years.ago.to_date)
        recent = create(:salary_history, employee: employee, effective_date: 1.month.ago.to_date)
        future = create(:salary_history, employee: employee, effective_date: 1.month.from_now.to_date)

        results = SalaryHistory.as_of(Date.current)
        expect(results).to include(past, recent)
        expect(results).not_to include(future)
      end
    end
  end
end
