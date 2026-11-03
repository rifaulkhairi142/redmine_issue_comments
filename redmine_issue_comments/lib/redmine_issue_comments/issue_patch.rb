module RedmineIssueComments
  module IssuePatch
    def self.included(base)
      base.class_eval do
        has_many :issue_comments, -> { order(:created_on, :id) }, dependent: :delete_all
      end
    end
  end
end
