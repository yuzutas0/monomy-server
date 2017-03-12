class Event < ActiveRecord::Base
  include SearchableEvent

  def self.create_index
    self.__elasticsearch__.client = Elasticsearch::Client.new host: 'https://host:port' # TODO: set value
    self.__elasticsearch__.client.indices.delete index: self.index_name rescue nil
    self.create_index! force: true
    self.__elasticsearch__.import
  end

  def self.show_index(query, page, per)
    response = self.search(query).page(page).per(per).records
  end

  def more_like_this!
    self.more_like_this().records
  end
end
