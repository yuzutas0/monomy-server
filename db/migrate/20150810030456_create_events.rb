class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :source_id, null: false
      t.string :source_event_id, null: false
      t.string :title, null: false
      t.text :catchtext
      t.text :description
      t.text :detail_url, null: false
      t.string :hash_tag
      t.datetime :started_at
      t.datetime :ended_at
      t.string :pay_type
      t.string :event_type
      t.text :reference_url
      t.integer :limit
      t.text :adress
      t.text :place
      t.string :lat
      t.string :lon
      t.string :owner_id
      t.text :owner_profile_url
      t.string :owner_nickname
      t.string :owner_twitter_id
      t.string :owner_display_name
      t.integer :accepted
      t.integer :waiting
      t.text :banner
      t.datetime :source_published_at
      t.datetime :source_updated_at, null: false
      t.string :series_id
      t.string :series_title
      t.string :series_country_code
      t.text :series_logo
      t.text :series_description
      t.text :series_url
      t.integer :delete_flag

      t.timestamps null: false
    end
  end
end
