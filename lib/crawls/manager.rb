# encoding: utf-8
class Crawls::Manager

	# rails runner Crawls::Manager.execute
	def self.execute
		Crawls::Robots::Atnd.execute
		Crawls::Robots::Doorkeeper.execute
		Crawls::Robots::Zusaar.execute
		Crawls::Robots::Connpass.execute
	end

end