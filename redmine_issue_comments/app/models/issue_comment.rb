class IssueComment < ApplicationRecord
  belongs_to :issue
  belongs_to :user
  belongs_to :parent, class_name: 'IssueComment', optional: true, inverse_of: :replies
  has_many :replies, -> { order(:created_on, :id) }, class_name: 'IssueComment',
           foreign_key: :parent_id, dependent: :delete_all, inverse_of: :parent

  validates :issue, :user, presence: true
  validates :content, presence: true, length: { maximum: 65_535 }
  validate :parent_must_be_top_level_on_same_issue

  delegate :project, to: :issue

  def reply?
    parent_id.present?
  end

  def edited?
    created_on.present? && updated_on.present? && updated_on > created_on + 1.second
  end

  def editable_by?(usr)
    usr.allowed_to?(:edit_issue_comments, project) ||
      (own?(usr) && usr.allowed_to?(:edit_own_issue_comments, project))
  end

  def deletable_by?(usr)
    usr.allowed_to?(:delete_issue_comments, project) ||
      (own?(usr) && usr.allowed_to?(:delete_own_issue_comments, project))
  end

  private

  def own?(usr)
    usr.logged? && user_id == usr.id
  end

  # One reply level only: parent must be a top-level comment on the same issue.
  def parent_must_be_top_level_on_same_issue
    return if parent.nil?

    errors.add(:parent, :invalid) unless parent.issue_id == issue_id && !parent.reply?
  end
end
