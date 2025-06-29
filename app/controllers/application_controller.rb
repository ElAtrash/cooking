class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has()
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: "The requested resource was not found." }
      format.json { render json: { error: "Not found" }, status: :not_found }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_messages",
        partial: "shared/flash", locals: { type: :alert, message: "Not found." }) }
    end
  end

  def bad_request
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: "Invalid request.") }
      format.json { render json: { error: "Bad request" }, status: :bad_request }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_messages",
        partial: "shared/flash", locals: { type: :alert, message: "Invalid request." }) }
    end
  end

  # Helper method to get current user for views
  def current_user
    Current.user
  end
  helper_method :current_user
end
