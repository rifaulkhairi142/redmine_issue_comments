module RedmineIssueComments
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom, partial: 'issue_comments/issue_comments'
  end
end
