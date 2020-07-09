require 'rails_helper'

RSpec.describe 'HeartbeatsController', type: :request do
  describe "POST create" do
    let(:params) do
      {
        id:            Faker::String.random(length: 4),
        url:           Faker::Internet.url(host: 'example.com'),
        current_calls: current_calls,
        sent_at:       DateTime.now,
        capacity:      5,
        provider:      "aws",
        type:          "t.2"
      }
    end
    let(:current_calls) { 4.times.map { Faker::String.random(length: 4) } }

    subject { post heartbeats_path, params: params }

    it "creates a heartbeat" do
      expect { subject }.to change(Heartbeat, :count).by(1)
    end

    it "returns status 200" do
      subject
      expect(response.status).to eq(200)
    end

    context "with same amount of current_calls as capacity" do
      let(:current_calls) { 5.times.map { Faker::String.random(length: 4) } }

      it "creates a heartbeat" do
        expect { subject }.to change(Heartbeat, :count).by(1)
      end
  
      it "returns status 200" do
        subject
        expect(response.status).to eq(503)
      end
    end
  end
end
