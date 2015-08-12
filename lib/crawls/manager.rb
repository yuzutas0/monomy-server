# encoding: utf-8
class Crawls::Manager

	# rails runner Crawls::Manager.execute
	def self.execute
		Crawls::Robots::Atnd.execute
		Crawls::Robots::Doorkeeper.execute
		Crawls::Robots::Zusaar.execute
		Crawls::Robots::Connpass.execute
	end

	# rails runner Crawls::Manager.test
	def self.test
		Event.create_index
		for event in Event.show_index('Ruby', 2)
			puts event.title
		end
	end

end