class ApplicationController < ActionController::Base

  rescue_from ActiveRecord::RecordNotFound do |exception|
    head 404
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    render_error(exception.record, 422)
  end

  # rescue_from LockedUser do |exception|
  #   render json: {
  #     status: "error",
  #     message: exception.message,
  #     pointers: "Usuario bloqueado",
  #     code: 3000
  #   }, status: 423
  # end

  rescue_from ActionController::NotImplemented do |exception|
    render json: {
      status: "error",
      message: exception.message,
      pointers: "Method is not implemented correctly",
      code: 3000
    }, status: :not_implemented
  end

  private

  def render_collection(collection, args = {})
    meta = params[:page].present? ? {
        page: params[:page] || 1,
        per: params[:per] || 100,
        pages: args[:total_pages] || collection.total_pages,
        total_records: args[:total_records]
      } : { total_records: total_model_records(collection) }
    render json: collection, meta: meta, **args
  end

  def total_model_records(collection)
    collection.try(:model).try(:count) || collection.first.class.count
  end

  def render_resource(record, **args)
    if !record.errors.empty?
      render_error(record)
    else
      render json: record, **args
    end
  end

  def render_error(record = nil, message = nil, status = 422)
    render json: {
      status: "error",
      message: message || record.try(:errors).try(:full_messages),
      pointers: record.try(:errors).try(:messages),
      code: 3000
    }, status: status
  end
end
