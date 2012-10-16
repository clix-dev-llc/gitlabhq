# Controller for viewing a repository's file structure
class TreeController < ProjectResourceController
  include ExtractsPath

  # Authorize
  before_filter :authorize_read_project!
  before_filter :authorize_code_access!
  before_filter :require_non_empty_project

  before_filter :assign_ref_vars
  before_filter :edit_requirements, only: [:edit, :update]

  def show
    @hex_path  = Digest::SHA1.hexdigest(@path)
    @logs_path = logs_file_project_ref_path(@project, @ref, @path)

    respond_to do |format|
      format.html
      # Disable cache so browser history works
      format.js { no_cache_headers }
    end
  end

  def edit
    @last_commit = @project.last_commit_for(@ref, @path).sha
  end

  def update
    file_editor = Gitlab::FileEditor.new(current_user, @project, @ref)
    update_status = file_editor.update(
      @path,
      params[:content],
      params[:commit_message],
      params[:last_commit]
    )

    if update_status
      redirect_to project_tree_path(@project, @id), notice: "Your changes have been successfully commited"
    else
      flash[:notice] = "Your changes could not be commited, because the file has been changed"
      render :edit
    end
  end

  private

  def edit_requirements
    unless @tree.is_blob? && @tree.text?
      redirect_to project_tree_path(@project, @id), notice: "You can only edit text files"
    end
  end
end
