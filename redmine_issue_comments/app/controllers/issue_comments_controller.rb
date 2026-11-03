class IssueCommentsController < ApplicationController
  before_action :find_issue, only: [:create]
  before_action :find_comment, only: [:update, :destroy]
  before_action :authorize

  def create
    @comment = @issue.issue_comments.build(comment_params)
    @comment.user = User.current
    @comment.parent = find_parent
    if @comment.save
      flash[:notice] = l(:notice_issue_comment_added)
    else
      flash[:error] = @comment.errors.full_messages.join(', ')
    end
    redirect_to_issue
  end

  def update
    return deny_access unless @comment.editable_by?(User.current)

    if @comment.update(comment_params)
      flash[:notice] = l(:notice_successful_update)
    else
      flash[:error] = @comment.errors.full_messages.join(', ')
    end
    redirect_to_issue
  end

  def destroy
    return deny_access unless @comment.deletable_by?(User.current)

    @comment.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to issue_path(@issue, anchor: 'issue-comments')
  end

  private

  def comment_params
    params.require(:issue_comment).permit(:content)
  end

  # Reply to a reply is flattened to the top-level comment it belongs to.
  def find_parent
    parent_id = params.dig(:issue_comment, :parent_id)
    return nil if parent_id.blank?

    parent = @issue.issue_comments.find_by(id: parent_id)
    parent&.reply? ? parent.parent : parent
  end

  def redirect_to_issue
    anchor = @comment.persisted? ? "issue-comment-#{@comment.id}" : 'issue-comments'
    redirect_to issue_path(@issue, anchor: anchor)
  end

  def find_issue
    @issue = Issue.visible.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_comment
    @comment = IssueComment.find(params[:id])
    @issue = @comment.issue
    raise ActiveRecord::RecordNotFound unless @issue.visible?

    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
