class MailsController < ApplicationController

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

	def show
		begin
			@event = Event.find(params[:id])
		rescue
			return redirect_to root_path
		end

		@recommends = get_recommends @event
	end

	def create
		begin
			@event = Event.find(params[:event][:id])
		rescue
			return redirect_to root_path
		end
		@recommends = get_recommends @event

		mail = params[:mail][:adress]
		return redirect_to mail_path(@event.id), alert: 'Input Email!!' if mail.blank?
		return redirect_to mail_path(@event.id), alert: 'Email Is Wrong!!' if mail !~ VALID_EMAIL_REGEX
		# TODO: send mail
		return redirect_to mail_path(@event.id), notice: 'Success Sent!!'
	end

	private
		def get_recommends event
			recommends = event.more_like_this
			begin
				if recommends.blank?
					puts "not find recommends"
					return nil
				end
			rescue Exception => e
				puts "not find recommends"
				return nil
			end
			return recommends
		end

end