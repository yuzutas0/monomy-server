class EventsController < ApplicationController

	PER_EVENTS = 30

	def index
		# search
		if params[:freeword].present? && params[:freeword][:content].present?
			begin
				@events = Event.show_index(params[:freeword][:content], params[:page], PER_EVENTS)
				return if @events.present?
			rescue
				redirect_to root_path, alert: 'ERROR!!'
			end
		end

		# not-search list
		source_list = [params[:source_id]] if params[:source_id].present?
		source_list = 1..4 if source_list.blank?
		@events = Event.where("source_id IN (?)", source_list).page(params[:page]).per(PER_EVENTS).order(:source_updated_at).reverse_order
	end

	def show
		@event = Event.find(params[:id])
		recommends = @event.more_like_this
		begin
			@recommends = recommends if recommends.present?			
		rescue Exception => e
			puts "not find recommends"
		end
	end

end
