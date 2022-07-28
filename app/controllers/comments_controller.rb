class CommentsController < ApplicationController
  def create

    @comment = current_user.comments.create(comment_params)
    @comment.body = helpers.purify @comment.body
    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to @comment.commentable, notice: "Commented successfully." }
        # format.json { render :show, status: :created, location: @commentable }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("#{helpers.dom_id(@comment)}_form", partial: 'form', locals: { commentable: @commentable, comment: @comment })
        }
        format.html { render :new, status: :unprocessable_entity }
        # format.json { render json: @commentable.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|

      @comment = current_user.comments.find(params[:id])
      @comment.destroy
      @comment.broadcast_remove_to [@comment.commentable, :comments], target: "#{helpers.dom_id @comment}"
      format.html { redirect_to @comment.commentable, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      unless @comment.update(comment_params)
        format.html { redirect_to commentable_path(@commentable), alert: "Comment was not updated." }
      end
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type)
  end

end
