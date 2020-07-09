class CallsController < ApplicationController
  def create
    call = Call.create(body: call_params)
    CallServiceWorker.perform_async(call.id)
    render json: { status: :ok }, status: :ok
  end

  private

  def call_params
    params.permit(
      :domain,
      :number_attribute,
      :number,
      :formatted_number,
      :observation_id,
      :caller_id,
      :endpoint,
      :bot_env,
      data: [:name, :phone, :address]
      contexts: [:attribute],
      voice: [:voice, :locale, :provider]
    )
  end
end

#   create: (request,response) => {

#     // synthesize bot audio (script is in script.json in root of project)
#     //   store on s3

#     // get bot server address

#     // call nexmo, start call, pass params

#     return response.status(200).json({status: "ok"})
#   }
# };
