class HeartbeatsController < ApplicationController
  def create
    @heartbeat = HeartbeatBuilderService.new(heartbeat_params).call
    render json: { status: :ok }, status: :ok
  end

  def heartbeat_params
    params.permit(:id, :url, :sent_at, :capacity, :provider, :type, current_calls: [])
  end
end


#   // accept data about available servers, so that we know where to route the next call that comes in
#   // {
#   //   id:            uuid,
#   //   url:           string, websocket url
#   //   current_calls: [uuids], array of ids of the current calls in progress
#   //   sent_at:       timestamp,
#   //   capacity:      integer, estimate of capacity of total capacity of calls this server can handle
#   //   provider:      string, ie aws
#   //   type:          string, ie micro t.2
#   // }


# // store data

# return response.status(200).json({status: "ok"})