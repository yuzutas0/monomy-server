class EventsController < ApplicationController

	def index
		source_list = [params[:source_id]] if params[:source_id].present?
		source_list = 1..4 if source_list.blank?
		@events = Event.where("source_id IN (?)", source_list).page(params[:page]).per(50).order(:source_updated_at).reverse_order
	end

	def show
		@event = Event.find(params[:id])
	end

end
