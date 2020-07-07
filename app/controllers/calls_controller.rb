class CallsController < ApplicationController
  def create
    call = Call.create(body: call_params)
    CallServiceWorker.perform_async(call.id)
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

#   // we can call this endpoint to initiate a call
#   // calls are actually performed by different servers, but this server needs to do 3 functions:
#   // 1. presynthesize the audios to s3
#   // 2. load balance the bot call servers so we dont overload one while others are idle
#   // 3. initiate the call by calling nexmo

#   // sample body
#   // {
#   //   "contexts": [
#   //     {
#   //       "attribute": "name"
#   //     },
#   //     {
#   //       "attribute": "address"
#   //     }
#   //   ],
#   //   "domain": "https://api.dataplor.com",
#   //   "number_attribute": "phone",
#   //   "number": "528343160366",
#   //   "data": {
#   //     "name": "Restaurante Don Jorge",
#   //     "phone": "+528343160366",
#   //     "address": "Av Tamaulipas 1100"
#   //   },
#   //   "formatted_number": "+528343160366",
#   //   "observation_id": "1626a2c4-ab0d-4f52-8420-851c171e78ec",
#   //   "caller_id": "525588969150",
#   //   "voice": {
#   //     "voice": "Lupe",
#   //     "locale": "es-US",
#   //     "provider": "aws"
#   //   },
#   //   "endpoint": "https://dataplor-lite-bot-prod.azurewebsites.net/outbound/makecall",
#   //   "bot_env": "production"
#   // }
#   create: (request,response) => {

#     // synthesize bot audio (script is in script.json in root of project)
#     //   store on s3

#     // get bot server address

#     // call nexmo, start call, pass params

#     return response.status(200).json({status: "ok"})
#   }
# };
