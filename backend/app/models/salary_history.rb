class SalaryHistory < ApplicationRecord
  REASONS = %w[hire promotion merit_increase cost_of_living correction].freeze

  # ── Associations ──────────────────────────────────────────────────────────
  belongs_to :employee

  # ── Validations ───────────────────────────────────────────────────────────
  validates :gross_salary,   presence: true,
                             numericality: { greater_than: 0 }
  validates :effective_date, presence: true
  validates :reason, inclusion: { in: REASONS }, allow_nil: true

  # ── Scopes ────────────────────────────────────────────────────────────────
  scope :chronological, -> { order(effective_date: :desc) }
  scope :as_of, ->(date) { where(effective_date: ..date) }
end
