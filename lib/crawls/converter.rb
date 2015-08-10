# encoding: utf-8
class Crawls::Converter

	# rails runner Crawls::Converter.updateEvent(old_event, new_event)
	def self.updateEvent(old_event, new_event)
		old_event.update_attributes = { :source_id => new_event.source_id,
																		:source_event_id => new_event.source_event_id,
																		:title => new_event.title,
																		:catchtext => new_event.catchtext,
																		:description => new_event.description,
																		:detail_url => new_event.detail_url,
																		:hash_tag => new_event.hash_tag,
																		:started_at => new_event.started_at,
																		:ended_at => new_event.ended_at,
																		:pay_type => new_event.pay_type,
																		:event_type => new_event.event_type,
																		:reference_url => new_event.reference_url,
																		:limit => new_event.limit,
																		:adress => new_event.adress,
																		:place => new_event.place,
																		:lat => new_event.lat,
																		:lon => new_event.lon,
																		:owner_id => new_event.owner_id,
																		:owner_profile_url => new_event.owner_profile_url,
																		:owner_nickname => new_event.owner_nickname,
																		:owner_twitter_id => new_event.owner_twitter_id,
																		:owner_display_name => new_event.owner_display_name,
																		:accepted => new_event.accepted,
																		:waiting => new_event.waiting,
																		:banner => new_event.banner,
																		:source_published_at => new_event.source_published_at,
																		:source_updated_at => new_event.source_updated_at,
																		:series_id => new_event.series_id,
																		:series_title => new_event.series_title,
																		:series_country_code => new_event.series_country_code,
																		:series_logo => new_event.series_logo,
																		:series_description => new_event.series_description,
																		:series_url => new_event.series_url }
	end

	# rails runner Crawls::Converter.getEvent(source_id, source_array)
	def self.getEvent(source_id, source_array)
		
		event = Event.new
		event.source_id = source_id

		if [1, 3, 4].include?(source_id)
			event.source_event_id = source_array['event_id']
		elsif source_id == 2
			event.source_event_id = source_array['id']
		end

		event.title = source_array['title']
		event.catchtext = source_array['catch']
		event.description = source_array['description']

		if [1, 3, 4].include?(source_id)
			event.detail_url = source_array['event_url']
		elsif source_id == 2
			event.detail_url = source_array['public_url']
		end

		event.hash_tag = source_array['hash_tag']

		if [1, 3, 4].include?(source_id)
			event.started_at = source_array['started_at']
		elsif source_id == 2
			event.started_at = source_array['starts_at']
		end

		if [1, 3, 4].include?(source_id)
			event.ended_at = source_array['ended_at']
		elsif source_id == 2
			event.ended_at = source_array['ends_at']
		end

		event.pay_type = source_array['pay_type']
		event.event_type = source_array['event_type']
		event.reference_url = source_array['url']

		if [1, 3, 4].include?(source_id)
			event.limit = source_array['limit']
		elsif source_id == 2
			event.limit = source_array['ticket_limit']
		end

		event.adress = source_array['address']

		if [1, 3, 4].include?(source_id)
			event.place = source_array['place']
		elsif source_id == 2
			event.place = source_array['venue_name']
		end

		event.lat = source_array['lat']

		if [1, 3, 4].include?(source_id)
			event.lon = source_array['lon']
		elsif source_id == 2
			event.lon = source_array['long']
		end

		event.owner_id = source_array['owner_id']
		event.owner_profile_url = source_array['owner_profile_url']
		event.owner_nickname = source_array['owner_nickname']
		event.owner_twitter_id = source_array['owner_twitter_id']
		event.owner_display_name = source_array['owner_display_name']

		if [1, 3, 4].include?(source_id)
			event.accepted = source_array['accepted']
		elsif source_id == 2
			event.accepted = source_array['participants']
		end
			
		if [1, 3, 4].include?(source_id)
			event.waiting = source_array['waiting']
		elsif source_id == 2
			event.waiting = source_array['waitlisted']
		end
				
		event.banner = source_array['banner']
		event.source_published_at = source_array['published_at']
		event.source_updated_at = source_array['updated_at']

		if source_id == 2 && source_array['group'].present?
			event.series_id = source_array['group']['id']
			event.series_title = source_array['group']['name']
			event.series_country_code = source_array['group']['country_code']
			event.series_logo = source_array['group']['logo']
			event.series_description = source_array['group']['description']
			event.series_url = source_array['group']['public_url']
		elsif source_id == 4 && source_array['series'].present?
			event.series_id = source_array['series']['id']
			event.series_title = source_array['series']['title']
			event.series_country_code = nil
			event.series_logo = nil
			event.series_description = nil
			event.series_url = source_array['series']['url']
		end

		return event
	end

end





# --------------------------------------------------------------------
# Response Param
# --------------------------------------------------------------------
#
# event
# ┣ [id]：デフォルト
# ┣ [created_at]：デフォルト
# ┣ [updated_at]：デフォルト
# ┣ [source_id]：情報取得元はどのサイトか（関連テーブル：Source）
# 	┗ 1:ATND, 2:Doorkeeper, 3:Zusaar, 4:Connpass
# 
# ┣ [source_event_id] event_id / id：各サイトでのID
# ┣ [title] title：タイトル
# ┣ [catch] catch：キャッチ => サブタイトルのようなもの
# ┣ [description] description：概要
# ┣ [detail_url] event_url / public_url：イベント詳細ページURL
# ┣ [hash_tag] hash_tag：Twitterのハッシュタグ
# ┣ [started_at] started_at / starts_at：イベント開催日時
# ┣ [ended_at] ended_at / ends_at：イベント終了日時
# ┣ [pay_type] pay_type：無料／有料イベント
# ┣ [event_type] event_type：イベント参加タイプ（参加受付/告知のみ）
# ┣ [reference_url] url：参考URL
# ┣ [limit] limit / ticket_limit：定員
# ┣ [adress] address：開催場所
# ┣ [place] place / venue_name：開催会場
# ┣ [lat] lat：開催会場の緯度
# ┣ [lon] lon / long：開催会場の経度
# ┣ [owner_id] owner_id：主催者のID
# ┣ [owner_profile_url] owner_profile_url：主催者のプロフィールURL
# ┣ [owner_nickname] owner_nickname：主催者のニックネーム
# ┣ [owner_twitter_id] owner_twitter_id：主催者のtwitter ID
# ┣ [owner_display_name] owner_display_name：主催者の表示名
# ┣ [accepted] accepted / participants：参加者
# ┣ [waiting] waiting / waitlisted：補欠者
# ┣ [banner] banner：バナー画像
# ┣ [source_published_at] published_at：公開日時
# ┣ [source_updated_at] updated_at：更新日時（＊カラム名が重複する問題）
# ┗ series / group：グループ
# 	┣ [series_id] id
# 	┣ [series_title] title / name
# 	┣ [series_country_code] country_code
# 	┣ [series_logo] logo
# 	┣ [series_description] description
# 	┗ [series_url] url / public_url
