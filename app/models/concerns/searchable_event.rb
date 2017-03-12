module SearchableEvent
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # customize the index name
    index_name 'event'

    # Set up index configuration and mapping
    settings index: {
        number_of_shards: 1,
        number_of_replicas: 0,
        analysis: {
            filter: {
                pos_filter: {
                    type: 'kuromoji_part_of_speech',
                    stoptags: %w(助詞-格助詞-一般 助詞-終助詞)
                },
                greek_lowercase_filter: {
                    type: 'lowercase',
                    language: 'greek'
                }
            },
            tokenizer: {
                kuromoji: {
                    type: 'kuromoji_tokenizer'
                },
                ngram_tokenizer: {
                    type: 'nGram',
                    min_gram: '2',
                    max_gram: '3',
                    token_chars: %w(letter digit)
                }
            },
            analyzer: {
                kuromoji_analyzer: {
                    type: 'custom',
                    tokenizer: 'kuromoji_tokenizer',
                    filter: %w(kuromoji_baseform pos_filter greek_lowercase_filter cjk_width)
                },
                ngram_analyzer: {
                    tokenizer: 'ngram_tokenizer'
                }
            }
        }
    } do
      mapping do
        indexes :id, type: 'integer', index: 'not_analyzed'
        indexes :source_id, type: 'integer', index: 'not_analyzed'
        indexes :source_event_id, type: 'integer', index: 'not_analyzed'
        indexes :title, type: 'string', index: 'analyzed', analyzer: 'kuromoji_analyzer'
        indexes :catchtext, type: 'string', index: 'analyzed', analyzer: 'kuromoji_analyzer'
        indexes :description, type: 'string', index: 'analyzed', analyzer: 'kuromoji_analyzer'
        indexes :detail_url, type: 'string', index: 'not_analyzed'
        indexes :hash_tag, type: 'string', index: 'not_analyzed'
        indexes :started_at, type: 'date', index: 'not_analyzed'
        indexes :ended_at, type: 'date', index: 'not_analyzed'
        indexes :pay_type, type: 'string', index: 'not_analyzed'
        indexes :event_type, type: 'string', index: 'not_analyzed'
        indexes :reference_url, type: 'string', index: 'not_analyzed'
        indexes :limit, type: 'integer', index: 'not_analyzed'
        indexes :adress, type: 'string', index: 'not_analyzed'
        indexes :place, type: 'string', index: 'not_analyzed'
        indexes :lat, type: 'string', index: 'not_analyzed'
        indexes :lon, type: 'string', index: 'not_analyzed'
        indexes :owner_id, type: 'string', index: 'not_analyzed'
        indexes :owner_profile_url, type: 'string', index: 'not_analyzed'
        indexes :owner_nickname, type: 'string', index: 'not_analyzed'
        indexes :owner_twitter_id, type: 'string', index: 'not_analyzed'
        indexes :owner_display_name, type: 'string', index: 'not_analyzed'
        indexes :accepted, type: 'integer', index: 'not_analyzed'
        indexes :waiting, type: 'integer', index: 'not_analyzed'
        indexes :banner, type: 'string', index: 'not_analyzed'
        indexes :source_published_at, type: 'date', index: 'not_analyzed'
        indexes :source_updated_at, type: 'date', index: 'not_analyzed'
        indexes :series_id, type: 'string', index: 'not_analyzed'
        indexes :series_title, type: 'string', index: 'analyzed', analyzer: 'kuromoji_analyzer'
        indexes :series_country_code, type: 'string', index: 'not_analyzed'
        indexes :series_logo, type: 'string', index: 'not_analyzed'
        indexes :series_description, type: 'string', index: 'analyzed', analyzer: 'kuromoji_analyzer'
        indexes :series_url, type: 'string', index: 'not_analyzed'
        indexes :created_at, type: 'date', index: 'not_analyzed'
        indexes :updated_at, type: 'date', index: 'not_analyzed'
      end
    end
  end

  def more_like_this(mlt_fields: 'title,catchtext,description,series_title,series_description', min_doc_freq: 0, min_term_freq: 0, min_word_len: 0, search_size: 5, body: {})
    target_id = self.id
    es = __elasticsearch__
    searcher = Class.new do
      define_method(:execute!) do
        begin
          es.client.mlt(
              search_size: search_size,
              index: es.index_name,
              type: es.document_type,
              body: body,
              id: target_id,
              mlt_fields: mlt_fields,
              min_doc_freq: min_doc_freq,
              min_term_freq: min_term_freq,
              min_word_len: min_word_len
          )
        rescue
          return nil
        end
      end
    end.new
    Elasticsearch::Model::Response::Response.new(self.class, searcher)
  end

  module ClassMethods
    def create_index!(options={})
      client = __elasticsearch__.client
      client.indices.delete index: 'event' rescue nil if options[:force]
      client.indices.create index: 'event',
                            body: {
                                settings: settings.to_hash,
                                mappings: mappings.to_hash
                            }
    end
  end
end