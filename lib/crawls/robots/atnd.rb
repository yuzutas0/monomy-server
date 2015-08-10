# encoding: utf-8
class Crawls::Robots::Atnd

	require 'open-uri'
	require 'kconv'
	require 'json'

	SOURCE_ID = 1

	# rails runner Crawls::Robots::Atnd.execute
	def self.execute
		puts "ATND"

		# loop : yymm (e.g. 201508 - 201512)
		date = Date.today
		for after_month in 0..4

			# loop : start (1, 101, 201, ..., last)
			date_string = (date >> after_month).strftime("%Y%m")
			start_count = 1
			get_count = 100
			loop do

				# HTTP
				request_uri = "http://api.atnd.org/events/?format=json&ym=" + date_string + "&count=" + get_count.to_s + "&start=" + start_count.to_s
				response = open(request_uri, &:read).toutf8
				sleep(2)

				# JSON Parse
				json = JSON.parser.new(response)
				hash =  json.parse()
				parsed = hash['events']
				break unless parsed.length > 0

				# ready for bulk insert / update
				insert_list = []

				# loop : event 
				parsed.each do |event_outer|
					event_inner = event_outer['event']
					new_event = Crawls::Converter.getEvent(SOURCE_ID, event_inner)

					# find same event
					next if new_event.source_id.blank? || new_event.source_event_id.blank?
					find_event_query = "source_id = :source_id AND source_event_id = :source_event_id"
					old_event = Event.where(find_event_query, source_id: new_event.source_id, source_event_id: new_event.source_event_id)
					
					if old_event.present?
						# update
						next if new_event.source_updated_at <= old_event.source_updated_at
						Crawls::Converter.updateEvent(old_event, new_event)
					else
						# add insert list
						insert_list << new_event
					end
				end

				# bulk insert
				Event.import(insert_list)

				# ready for next-loop
				break if parsed.length < get_count
				start_count += parsed.length
			end
		end
	end

end





# --------------------------------------------------------------------
# Document
# --------------------------------------------------------------------
# http://api.atnd.org/
# 
#
#
# --------------------------------------------------------------------
# Request Param
# --------------------------------------------------------------------
# http://api.atnd.org/events/?
#
# ym
# => イベント開催年月（例：200909）
# => 実際に投げるクエリは現在＋5ヶ月分（例：201507から201512）
#
# start
# => 検索の開始位置（初期値：1）
# => 実際に投げるクエリは1,101,201...
#
# count
# => 取得件数（初期値：10、最小値：1、最大値：100）
# => 実際に投げるクエリは100
# 
# format
# => レスポンス形式（初期値：xml）
# => 実際に投げるクエリはjson
#
#
#
# --------------------------------------------------------------------
# Response Param
# --------------------------------------------------------------------
# results_returned（含まれる検索結果の件数）
# => 0になったらページネーション終了
#
# events
# ┗ event（複数要素）
# 　┣ event_id：イベントID
# 　┣ title：タイトル
# 　┣ catch：キャッチ => サブタイトルのようなもの
# 　┣ description：概要
# 　┣ event_url：ATNDのURL => イベント詳細ページURL
# 　┣ started_at：イベント開催日時
# 　┣ ended_at：イベント終了日時
# 　┣ url：参考URL
# 　┣ limit：定員
# 　┣ address：開催場所
# 　┣ place：開催会場
# 　┣ lat：開催会場の緯度
# 　┣ lon：開催会場の経度
# 　┣ owner_id：主催者のID
# 　┣ owner_nickname：主催者のニックネーム
# 　┣ owner_twitter_id：主催者のtwitter ID
# 　┣ accepted：参加者
# 　┣ waiting：補欠者
# 　┗ updated_at：更新日時 => 取得済みならページネーション終了
#
#
# 
# --------------------------------------------------------------------
# http://api.atnd.org/events/?keyword=google&format=json
# --------------------------------------------------------------------
# {
# 	"results_returned": 10,
# 	"results_start": 1,
# 	"events":
# 	[
# 		{
# 			"event": 
# 			{
# 				"event_id": 68181,
# 				"title": "\b【増員!!】\b【#TechBuzz】9/28 第14回 アプリマーケティング勉強会【テーマ：調整中！！】",
# 				"catch": null,
# 				"description": "<p>【テーマ：調整中！！】</p>\n<p>※TechBuzzの勉強会で発表を希望される方は、<a href=\"http://goo.gl/uUkxHr\">こちら</a>からお申し込みください！</p>\n<p><a href=\"http://www.socialtoprunners.jp/#!untitled/cv7f\">【TechBuzz】の取り組み</a><br />\n<a href=\"http://atnd.org/users/53621\" target=\"_blank\">【TechBuzz】開催予定まとめ</a></p>\n<p>※参加規約は<a href=\"http://www.socialtoprunners.jp/#!hatchupevents/c1pzg\">こちら</a><br />\n※営業や採用目的の方は参加できません！（受付時に確認致します）</p>\n<h3>■タイムテーブル</h3>\n<table>\n\t<tr>\n\t\t<td>時間</td>\n\t\t<td>発表者</td>\n\t\t<td>発表内容</td>\n\t</tr>\n\t<tr>\n\t\t<td>19:00-</td>\n\t\t<td><b>受付</td>\n\t\t<td><b></td>\n\t</tr>\n\t<tr>\n\t\t<td>19:40-</td>\n\t\t<td><b>調整中！！</td>\n\t\t<td><b></td>\n\t</tr>\n\t<tr>\n\t\t<td>20:40-</td>\n\t\t<td><b>ネットワーキングタイム</td>\n\t\t<td><b></td>\n\t</tr>\n</table>\n<h3>【発表者】</h3>\n<h4>調整中！！</h4>\n<h3>■参加対象者</h3>\n<p>・スマートフォンアプリ開発をしている方<br />\n・スマートフォンアプリのマーケティングについて知りたい方</p>\n<h3>■場所</h3>\n<p>Tech Buzz Space（代々木駅西口改札徒歩60秒です！）<br />\nアクセス地図は<a href=\"https://goo.gl/maps/eY3Fw\">こちら！</a></p>\n<h3>■持参していただくもの</h3>\n<p>●会場費 500円<br />\n●名刺(1枚)<br />\n※おつりの用意はございません！予めご了承ください。また、領収書の発行はできません<br />\n※なお、&quot;TechBuzzステッカー&quot;を貼ってる常連さん、学生さんは、名刺なしでOKです</p>\n<h3>■クリエイター・エンジニアの皆さん、転職希望の方へ</h3>\n<p>TechBuzzを運営するHatchUpでは、Web・スマート・IoT関連のクリエイター・エンジニアの皆さんの転職サポートをおこなっております。<br />\n特徴は、（１）企画開発運用現場のリーダー、責任者、担当役員クラスのアサインメントの実績、（２）チーム移籍やチームビルド、プロジェクト立ち上げの実績となっています。<br />\n少し先の転職を想定されている方も含め、個別相談ご希望の方は<br />\n<a href=\"https://docs.google.com/a/hatchup.co.jp/spreadsheet/embeddedform?formkey=dHBnd29MWVJfalVqS1pJeWZ4eHpvWkE6MQ\">こちら</a>からお申し込みください。<br />\nお仕事終わり・平日夜や、土日の個別相談も受け付けています。</p>\n<h3>■主催運営：<a href=\"http://www.socialtoprunners.jp/\">【ソーシャルスマートコミュニティ】HatchUp</a></h3>\n<p><a href=\"http://www.socialtoprunners.jp/#!techbuzz/cv7f \">&lt;img src=&#8220;http://u.jimdo.com/www57/o/sa9025d1b29b0d7f5/img/i8f2b0e3e647b9ece/1435219546/std/image.png&#8221; alt =&#8220;【イベント会場無償貸出し】&#8221; title =&quot;【イベント会場無償貸出し】&quot;&gt;</a></p>\n<h3>■弊社主催または、会場貸出し中イベント一覧</h3>\n<h4>【7/24】<a href=\"https://atnd.org/events/65468\">モバイル・コンシューマ「開発比較」勉強会 #2</a><br/>\n【7/28】<a href=\"https://atnd.org/events/65471\">第13回 アプリマーケティング勉強会</a><br/>\n【7/29】<a href=\"https://atnd.org/events/66217\">第33回代々木Unity勉強会</a><br/>\n【7/30】<a href=\"https://atnd.org/events/66218\">第15回 HTML5+JS 勉強会</a><br/>\n【8/24】<a href=\"https://atnd.org/events/66633\">第16回 HTML5+JS 勉強会</a><br/>\n【8/26】<a href=\"https://atnd.org/events/66634\">第14回cocos2d-x勉強会</a><br/>\n【9/24】<a href=\"https://atnd.org/events/68179\">第17回 HTML5+JS 勉強会</a><br/>\n【9/25】<a href=\"https://atnd.org/events/68180\">第34回代々木Unity勉強会</a><br/>\n【9/28】<a href=\"https://atnd.org/events/68181\">第14回 アプリマーケティング勉強会</a><br/>\nh3. ■ネット環境について</h4>\n<p>当日のネット環境ですが、状況が不安定なため、場合によってはご提供できない可能性もあります。必要が有る方は、ご自身の通信環境をご用意ください。ということで、通信環境はあくまでベストエフォート（状況次第）となりますが、以下のwifiをご利用ください</p>\n<p>id:pr500k-85430b-1<br />\npass:0c7321f59c4db</p>\n<p>id:pr500k-85430b-3<br />\npass:f0866853567b1</p>",
# 				"event_url": "http://atnd.org/events/68181",
# 				"started_at": "2015-09-28T19:30:00.000+09:00",
# 				"ended_at": "2015-09-28T22:00:00.000+09:00",
# 				"url": "http://www.socialtoprunners.jp/",
# 				"limit": 20,
# 				"address": "東京都渋谷区代々木1-27-16 JECビル 5F",
# 				"place": "代々木TechBuzzSpace（JECビル 5F）",
# 				"lat": "35.6823503",
# 				"lon": "139.70083",
# 				"owner_id": 53621,
# 				"owner_nickname": "ソーシャルスマートコミュニティ【TechBuzz】",
# 				"owner_twitter_id": "hatchup",
# 				"accepted": 1,
# 				"waiting": 0,
# 				"updated_at": "2015-07-09T12:03:41.000+09:00"
# 			}
# 		},
# 		{
# 			"event": 
# 			{
# 				"event_id": 68181,
# 				"title": "\b【増員!!】\b【#TechBuzz】9/28 第14回 アプリマーケティング勉強会【テーマ：調整中！！】",
# 				"catch": null,
# 				"description": "<p>【テーマ：調整中！！】</p>\n<p>※TechBuzzの勉強会で発表を希望される方は、<a href=\"http://goo.gl/uUkxHr\">こちら</a>からお申し込みください！</p>\n<p><a href=\"http://www.socialtoprunners.jp/#!untitled/cv7f\">【TechBuzz】の取り組み</a><br />\n<a href=\"http://atnd.org/users/53621\" target=\"_blank\">【TechBuzz】開催予定まとめ</a></p>\n<p>※参加規約は<a href=\"http://www.socialtoprunners.jp/#!hatchupevents/c1pzg\">こちら</a><br />\n※営業や採用目的の方は参加できません！（受付時に確認致します）</p>\n<h3>■タイムテーブル</h3>\n<table>\n\t<tr>\n\t\t<td>時間</td>\n\t\t<td>発表者</td>\n\t\t<td>発表内容</td>\n\t</tr>\n\t<tr>\n\t\t<td>19:00-</td>\n\t\t<td><b>受付</td>\n\t\t<td><b></td>\n\t</tr>\n\t<tr>\n\t\t<td>19:40-</td>\n\t\t<td><b>調整中！！</td>\n\t\t<td><b></td>\n\t</tr>\n\t<tr>\n\t\t<td>20:40-</td>\n\t\t<td><b>ネットワーキングタイム</td>\n\t\t<td><b></td>\n\t</tr>\n</table>\n<h3>【発表者】</h3>\n<h4>調整中！！</h4>\n<h3>■参加対象者</h3>\n<p>・スマートフォンアプリ開発をしている方<br />\n・スマートフォンアプリのマーケティングについて知りたい方</p>\n<h3>■場所</h3>\n<p>Tech Buzz Space（代々木駅西口改札徒歩60秒です！）<br />\nアクセス地図は<a href=\"https://goo.gl/maps/eY3Fw\">こちら！</a></p>\n<h3>■持参していただくもの</h3>\n<p>●会場費 500円<br />\n●名刺(1枚)<br />\n※おつりの用意はございません！予めご了承ください。また、領収書の発行はできません<br />\n※なお、&quot;TechBuzzステッカー&quot;を貼ってる常連さん、学生さんは、名刺なしでOKです</p>\n<h3>■クリエイター・エンジニアの皆さん、転職希望の方へ</h3>\n<p>TechBuzzを運営するHatchUpでは、Web・スマート・IoT関連のクリエイター・エンジニアの皆さんの転職サポートをおこなっております。<br />\n特徴は、（１）企画開発運用現場のリーダー、責任者、担当役員クラスのアサインメントの実績、（２）チーム移籍やチームビルド、プロジェクト立ち上げの実績となっています。<br />\n少し先の転職を想定されている方も含め、個別相談ご希望の方は<br />\n<a href=\"https://docs.google.com/a/hatchup.co.jp/spreadsheet/embeddedform?formkey=dHBnd29MWVJfalVqS1pJeWZ4eHpvWkE6MQ\">こちら</a>からお申し込みください。<br />\nお仕事終わり・平日夜や、土日の個別相談も受け付けています。</p>\n<h3>■主催運営：<a href=\"http://www.socialtoprunners.jp/\">【ソーシャルスマートコミュニティ】HatchUp</a></h3>\n<p><a href=\"http://www.socialtoprunners.jp/#!techbuzz/cv7f \">&lt;img src=&#8220;http://u.jimdo.com/www57/o/sa9025d1b29b0d7f5/img/i8f2b0e3e647b9ece/1435219546/std/image.png&#8221; alt =&#8220;【イベント会場無償貸出し】&#8221; title =&quot;【イベント会場無償貸出し】&quot;&gt;</a></p>\n<h3>■弊社主催または、会場貸出し中イベント一覧</h3>\n<h4>【7/24】<a href=\"https://atnd.org/events/65468\">モバイル・コンシューマ「開発比較」勉強会 #2</a><br/>\n【7/28】<a href=\"https://atnd.org/events/65471\">第13回 アプリマーケティング勉強会</a><br/>\n【7/29】<a href=\"https://atnd.org/events/66217\">第33回代々木Unity勉強会</a><br/>\n【7/30】<a href=\"https://atnd.org/events/66218\">第15回 HTML5+JS 勉強会</a><br/>\n【8/24】<a href=\"https://atnd.org/events/66633\">第16回 HTML5+JS 勉強会</a><br/>\n【8/26】<a href=\"https://atnd.org/events/66634\">第14回cocos2d-x勉強会</a><br/>\n【9/24】<a href=\"https://atnd.org/events/68179\">第17回 HTML5+JS 勉強会</a><br/>\n【9/25】<a href=\"https://atnd.org/events/68180\">第34回代々木Unity勉強会</a><br/>\n【9/28】<a href=\"https://atnd.org/events/68181\">第14回 アプリマーケティング勉強会</a><br/>\nh3. ■ネット環境について</h4>\n<p>当日のネット環境ですが、状況が不安定なため、場合によってはご提供できない可能性もあります。必要が有る方は、ご自身の通信環境をご用意ください。ということで、通信環境はあくまでベストエフォート（状況次第）となりますが、以下のwifiをご利用ください</p>\n<p>id:pr500k-85430b-1<br />\npass:0c7321f59c4db</p>\n<p>id:pr500k-85430b-3<br />\npass:f0866853567b1</p>",
# 				"event_url": "http://atnd.org/events/68181",
# 				"started_at": "2015-09-28T19:30:00.000+09:00",
# 				"ended_at": "2015-09-28T22:00:00.000+09:00",
# 				"url": "http://www.socialtoprunners.jp/",
# 				"limit": 20,
# 				"address": "東京都渋谷区代々木1-27-16 JECビル 5F",
# 				"place": "代々木TechBuzzSpace（JECビル 5F）",
# 				"lat": "35.6823503",
# 				"lon": "139.70083",
# 				"owner_id": 53621,
# 				"owner_nickname": "ソーシャルスマートコミュニティ【TechBuzz】",
# 				"owner_twitter_id": "hatchup",
# 				"accepted": 1,
# 				"waiting": 0,
# 				"updated_at": "2015-07-09T12:03:41.000+09:00"
# 			}
# 		}
# 	]
# }
