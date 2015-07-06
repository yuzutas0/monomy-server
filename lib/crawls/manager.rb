# encoding: utf-8
class Crawls::Manager

	# rails runner Crawls::Manager.execute
	def self.execute
		puts "test"
		Crawls::Converter.execute
		Crawls::Robots::Atnd.execute
	end

end