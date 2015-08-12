class Event < ActiveRecord::Base
	include SearchableEvent

	def self.create_index
		self.__elasticsearch__.client = Elasticsearch::Client.new host: 'localhost:9200'
		self.__elasticsearch__.client.indices.delete index: self.index_name rescue nil
		self.create_index! force: true
		self.__elasticsearch__.import
	end

	def self.show_index(query, page)
		response = self.search(query).page(page).results
	end

	def more_like_this!
		self.more_like_this(search_size: 3).results
	end
end
