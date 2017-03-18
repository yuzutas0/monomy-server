module Api
  module V1
    class CrawlsController < ApplicationController

      def execute
        id = params[:id]
        started_at = Time.now
        message = "OK"

        begin
          Event.create_index if id == "100"
          Crawls::Robots::Atnd.execute if id == "1"
          Crawls::Robots::Doorkeeper.execute if id == "2"
          Crawls::Robots::Zusaar.execute if id == "3"
          Crawls::Robots::Connpass.execute if id == "4"
        rescue => e
          message = e.message
        end

        finished_at = Time.now
        response = Response.new(message, started_at, finished_at)
        render json: response
      end

      private
      class Response
        def initialize(message, started_at, finished_at)
          @message = message
          @started_at = started_at
          @finished_at = finished_at
        end

        attr_accessor :message, :started_at, :finished_at
      end

    end
  end
end