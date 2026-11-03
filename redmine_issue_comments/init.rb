Redmine::Plugin.register :redmine_issue_comments do
  name 'Redmine Issue Comments'
  author 'lmswholesalebni7'
  description 'Adds a dedicated comment section to every issue detail page'
  version '1.0.0'
  requires_redmine version_or_higher: '6.0.0'

  project_module :issue_comments do
    permission :view_issue_comments, {}, read: true
    permission :add_issue_comments, { issue_comments: [:create] }
    permission :edit_own_issue_comments, { issue_comments: [:update] }
    permission :edit_issue_comments, { issue_comments: [:update] }
    permission :delete_own_issue_comments, { issue_comments: [:destroy] }
    permission :delete_issue_comments, { issue_comments: [:destroy] }
  end
end

# lib/ is autoloaded by Zeitwerk in Redmine 6; referencing the constants loads them.
unless Issue.included_modules.include?(RedmineIssueComments::IssuePatch)
  Issue.include RedmineIssueComments::IssuePatch
end
RedmineIssueComments::Hooks
