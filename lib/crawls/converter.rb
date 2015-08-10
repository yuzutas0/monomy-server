# encoding: utf-8
class Crawls::Converter

	# rails runner Crawls::Converter.execute
	def self.execute
		puts "test2"
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
