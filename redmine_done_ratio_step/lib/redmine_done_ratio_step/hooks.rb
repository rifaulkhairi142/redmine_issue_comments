module RedmineDoneRatioStep
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_layouts_base_html_head, partial: 'done_ratio_step/html_head'
    # Core dropdown only has multiples of 10, so an existing value like 37 is
    # not selected there. Expose the real value for the JS widget.
    render_on :view_issues_form_details_bottom, partial: 'done_ratio_step/issue_value'
  end
end
