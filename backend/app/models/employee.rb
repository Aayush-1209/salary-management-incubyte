class Employee < ApplicationRecord
  LEVELS = %w[Junior Mid Senior Staff Principal].freeze
  CURRENCIES = %w[USD EUR GBP INR AED SGD AUD CAD JPY BRL ZAR NGN KES].freeze

  # ── Associations ──────────────────────────────────────────────────────────
  has_many :salary_histories, dependent: :destroy

  # ── Validations ───────────────────────────────────────────────────────────
  validates :employee_number, presence: true, uniqueness: { case_sensitive: false }
  validates :email,           presence: true, uniqueness: { case_sensitive: false },
                              format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name,  presence: true
  validates :last_name,   presence: true
  validates :country,     presence: true
  validates :department,  presence: true
  validates :job_title,   presence: true
  validates :hired_on,    presence: true
  validates :currency,    presence: true, inclusion: { in: CURRENCIES }
  validates :level, inclusion: { in: LEVELS }, allow_nil: true

  # ── Scopes ────────────────────────────────────────────────────────────────
  scope :active,         -> { where(active: true) }
  scope :inactive,       -> { where(active: false) }
  scope :by_country,     ->(country) { where(country: country) }
  scope :by_department,  ->(dept)    { where(department: dept) }
  scope :by_currency,    ->(cur)     { where(currency: cur) }

  # ── Instance methods ──────────────────────────────────────────────────────
  def full_name
    "#{first_name} #{last_name}"
  end

  def current_salary
    salary_histories.chronological.first
  end
end
