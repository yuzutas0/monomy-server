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
# ┣ id：デフォルト
# ┣ created_at：デフォルト
# ┣ updated_at：デフォルト
# ┣ xxx：情報取得元はどのサイトか
# 
# ┣ event_id / id：各サイトでのID
# ┣ title：タイトル
# ┣ catch：キャッチ => サブタイトルのようなもの
# ┣ description：概要
# ┣ event_url / public_url：イベント詳細ページURL
# ┣ hash_tag：Twitterのハッシュタグ
# ┣ started_at / starts_at：イベント開催日時
# ┣ ended_at / ends_at：イベント終了日時
# ┣ pay_type：無料／有料イベント
# ┣ event_type：イベント参加タイプ（参加受付/告知のみ）
# ┣ url：参考URL
# ┣ limit / ticket_limit：定員
# ┣ address：開催場所
# ┣ place / venue_name：開催会場
# ┣ lat：開催会場の緯度
# ┣ lon / long：開催会場の経度
# ┣ owner_id：主催者のID
# ┣ owner_profile_url：主催者のプロフィールURL
# ┣ owner_nickname：主催者のニックネーム
# ┣ owner_twitter_id：主催者のtwitter ID
# ┣ owner_display_name：主催者の表示名
# ┣ accepted / participants：参加者
# ┣ waiting / waitlisted：補欠者
# ┣ banner：バナー画像
# ┣ published_at：公開日時
# ┣ updated_at：更新日時（＊カラム名が重複する問題）
# ┗ series / group：グループ
# 	┣ id
# 	┣ title / name
# 	┣ country_code
# 	┣ logo
# 	┣ description
# 	┗ url / public_url
