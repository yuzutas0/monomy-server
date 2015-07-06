# encoding: utf-8
class Crawls::Manager

	# rails runner Crawls::Manager.execute
	def self.execute
		puts "test" # => "test"
		Crawls::Converter.execute # => "test2"
		Crawls::Robots::Atnd.execute # => "test3"
	end

end