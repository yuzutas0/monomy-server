class EventsController < ApplicationController

	def index
		@events = Event.page(params[:page]).per(50).order(:source_updated_at).reverse_order
	end

	def show
		@event = Event.find(params[:id])
	end

end
