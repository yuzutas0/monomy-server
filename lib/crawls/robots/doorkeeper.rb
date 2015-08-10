# encoding: utf-8
class Crawls::Robots::Doorkeeper

	require 'open-uri'
	require 'kconv'
	require 'json'

	SOURCE_ID = 2

	# rails runner Crawls::Robots::Doorkeeper.execute
	def self.execute
		puts "Doorkeeper"

		# loop - start (1, 2, 3, ..., last)
		page = 1
		get_count = 25
		date = Date.today
		until_date = Date.today << 4
		loop do

			# HTTP
			request_uri = "http://api.doorkeeper.jp/events/?since=" + date.to_s + "&until" + until_date.to_s + "&page=" + page.to_s
			response = open(request_uri, &:read).toutf8
			sleep(2)

			# JSON Parse
			json = JSON.parser.new(response)
			parsed = json.parse()
			break unless parsed.length > 0

			# ready for bulk insert
			insert_list = []

			# loop : event
			parsed.each do |event_outer|
				event_inner = event_outer['event']
				new_event = Crawls::Converter.getEvent(SOURCE_ID, event_inner)

				# find same event
				next if new_event.source_id.blank? || new_event.source_event_id.blank?
				find_event_query = "source_id = :source_id AND source_event_id = :source_event_id"
				old_events = Event.where(find_event_query, source_id: new_event.source_id, source_event_id: new_event.source_event_id)
				old_event = old_events[0] if old_events.present?

				next if new_event.source_updated_at.blank?
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
			page += 1
		end
	end

end





# --------------------------------------------------------------------
# Document
# --------------------------------------------------------------------
# http://www.doorkeeperhq.com/developer/api
# 
#
#
# --------------------------------------------------------------------
# Request Param
# --------------------------------------------------------------------
# http://api.doorkeeper.jp/events/?
#
# page
# => 検索の開始位置（初期値：1）
# => 実際に投げるクエリは1,26,51...
# 
# sort
# => 実際に投げるクエリはstarts_at
#
#
#
# --------------------------------------------------------------------
# Response Param
# --------------------------------------------------------------------
# results_returned（含まれる検索結果の件数）
# => 0になったらページネーション終了
#
# event
# ┣ id：イベントID
# ┣ title：タイトル
# ┣ description：概要
# ┣ public_url：doorkeeper上のURL => イベント詳細ページURL
# ┣ starts_at：イベント開催日時
# ┣ ends_at：イベント終了日時
# ┣ ticket_limit：定員
# ┣ address：開催場所
# ┣ venue_name：開催会場
# ┣ lat：開催会場の緯度
# ┣ long：開催会場の経度
# ┣ published_at：公開日時（＊ATNDなし）
# ┣ updated_at：更新日時
# ┗ group（＊ATNDなし）
# 	┣ id
# 	┣ name
# 	┣ country_code
# 	┣ logo
# 	┣ description
# 	┗ public_url
# ┣ banner：バナー画像（＊ATNDなし）
# ┣ participants：参加者
# ┗ waitlisted：補欠者
#
#
#
# --------------------------------------------------------------------
# http://api.doorkeeper.jp/events
# --------------------------------------------------------------------
# [
# 	{
# 		"event": 
# 		{
# 			"title": "第43回勉強会(2015/07/25)",
# 			"id": 28284,
# 			"starts_at": "2015-07-25T04:00:00.000Z",
# 			"ends_at": "2015-07-25T09:00:00.000Z",
# 			"venue_name": "長岡市　まちなかキャンパス 301会議室",
# 			"address": "〒940-0062　新潟県長岡市大手通2-6 フェニックス大手イースト4F",
# 			"lat": "37.4474428",
# 			"long": "138.8496801",
# 			"ticket_limit": null,
# 			"published_at": "2015-07-12T22:39:53.687Z",
# 			"updated_at": "2015-07-12T22:39:53.691Z",
# 			"group": 
# 			{
# 				"id": 1554,
# 				"name": "長岡IT開発者勉強会 (NDS)",
# 				"country_code": "JP",
# 				"logo": "https://dzpp79ucibp5a.cloudfront.net/groups_logos/1554_normal_1371633709_NDS_logo1.jpg",
# 				"description": "<p>新潟県長岡市のIT系開発者が、自主的に勉強会を開催するために2008年11月に結成されたグループです。 <br>\n長岡市での勉強会の開催や、議論をを主な活動とします。 </p>\n\n<p>情報処理技術に関するものであれば、プログラミング技術、IT最新情報、開発手法、ITマネージメント、スーツネタなど幅広い範囲での学習を目指します。 </p>\n\n<p><a href=\"http://nagaoka.techtalk.jp/\">http://nagaoka.techtalk.jp/</a></p>\n",
# 				"public_url": "https://nagaoka-study.doorkeeper.jp/"
# 			},
# 			"banner": "https://dzpp79ucibp5a.cloudfront.net/events_banners/28284_normal_1436740776_NDS_logo1s.jpg",
# 			"description": "<h2>スーツ &amp; 品質</h2>\n\n<p>スーツネタとはいわゆるエンタープライズな分野のことです(スーツ着てるイメージがあるので)。<br>\nエンタープライズ向けなお話や、品質をキーワードにしたテーマセッションを募集します。<br>\nもちろんテーマ外のセッションも大歓迎です。</p>\n\n<p>公式告知ページはこちら<br>\n<a href=\"http://nagaoka.techtalk.jp/no43\">http://nagaoka.techtalk.jp/no43</a></p>",
# 			"public_url": "https://nagaoka-study.doorkeeper.jp/events/28284",
# 			"participants": 0,
# 			"waitlisted": 0
# 		}
# 	},
# 	{
# 		"event":
# 		{
# 			"title": "スプラウト.rb 第１３回",
# 			"id": 28280,
# 			"starts_at": "2015-07-25T04:00:00.000Z",
# 			"ends_at": "2015-07-25T08:00:00.000Z",
# 			"venue_name": "オープンソースラボ （島根県松江市）",
# 			"address": null,
# 			"lat": null,
# 			"long": null,
# 			"ticket_limit": null,
# 			"published_at": "2015-07-12T14:52:12.764Z",
# 			"updated_at": "2015-07-13T00:05:04.165Z",
# 			"group": 
# 			{
# 				"id": 2828,
# 				"name": "スプラウト.rb　-　Ruby on Rails 勉強会(読書会) -",
# 				"country_code": "JP",
# 				"logo": "https://dzpp79ucibp5a.cloudfront.net/groups_logos/2828_normal_1397321012_Sproutrb1.PNG",
# 				"description": "<h2>スプラウト.rb（sprout.rb）とは</h2>\n\n<p>Ruby on Railsを仲間と一緒に学びたい人のための勉強会(読書会) です。</p>\n\n<p>この勉強会の最大の目的は、継続的に学ぶことです。</p>\n\n<p>セミナーのように受講するというスタイルではなく</p>\n\n<p>仲間と「Ruby on Rails チュートリアル」を読み進めながらワークをしていきます。</p>\n\n<h2>対象レベル</h2>\n\n<ul>\n<li><p>まずは、教材とする「Ruby on Rails チュートリアル」の「1.1.1 読者の皆さまへ」を読んでください。<br>\n　<a href=\"http://railstutorial.jp/\">http://railstutorial.jp/</a></p></li>\n<li><p>基本的には、チュートリアルが対象としている【プログラミングの経験があり、これからWeb開発を始める方へ】以上のレベルを対象にします。<br>\n　だだし、【初めてプログラミングを始める方へ】に該当するけど、HTMLやCSSの基礎を自力で勉強してでも参加したい！という意気込みのある方は歓迎します。</p></li>\n</ul>\n\n<h2>勉強会でやること</h2>\n\n<ul>\n<li><p>「Ruby on Rails チュートリアル」を読み進めながらワーク<br>\n　<a href=\"http://railstutorial.jp/\">http://railstutorial.jp/</a></p></li>\n<li><p>必要に応じて、Gitの勉強なども</p></li>\n</ul>\n\n<h2>開催日</h2>\n\n<ul>\n<li><p>月１回</p></li>\n<li><p>当面はmatsue.rbと同日に開催</p></li>\n</ul>\n\n<h2>今後の開催予定日</h2>\n\n<ul>\n<li>Wikiの開催スケジュール参照<br>\n<a href=\"https://github.com/sproutrb/meetups/wiki/%E9%96%8B%E5%82%AC%E3%82%B9%E3%82%B1%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB\">https://github.com/sproutrb/meetups/wiki/開催スケジュール</a></li>\n</ul>\n\n<h2>開催場所</h2>\n\n<ul>\n<li><p>オープンソースラボ（島根県　松江市）</p></li>\n<li><p>当面はmatsue.rbの一画を使用させて頂く</p></li>\n</ul>\n\n<h2>開催時間</h2>\n\n<p>　　１３：００　～　１７：００  </p>\n\n<h2>参加募集</h2>\n\n<ul>\n<li>Doorkeeperから申し込み</li>\n</ul>\n\n<h2>PC環境について</h2>\n\n<ul>\n<li><p>Railsのバージョンは4.0</p></li>\n<li><p>Rubyのバージョンは2.0以上</p></li>\n<li><p>自分のPCに環境を用意する場合<br><br>\nインストーラーを使用して環境設定するならこちら<br><br>\n<a href=\"http://railsinstaller.org/en\">http://railsinstaller.org/en</a><br><br>\n例）Windowsの場合なら、緑色のボタン(Windows RUBY 2.1)をクリック  </p></li>\n<li><p>自分のPCに環境を用意せず nitrous.io の使用する場合 <br>\n<a href=\"https://www.nitrous.io/\">https://www.nitrous.io/</a><br>\nnitrous.io を始めるための手順はこちら<br><br>\n<a href=\"https://github.com/sproutrb/meetups/wiki/Nitorous.io-%E3%81%A7%E5%A7%8B%E3%82%81%E3%82%88%E3%81%86\">https://github.com/sproutrb/meetups/wiki/Nitorous.io-で始めよう</a></p></li>\n</ul>\n",
# 				"public_url": "https://sproutrb.doorkeeper.jp/"
# 			},
# 			"description": "<p>Ruby on Railsを仲間と一緒に学びたい人のための勉強会</p>",
# 			"public_url": "https://sproutrb.doorkeeper.jp/events/28280",
# 			"participants": 2,
# 			"waitlisted": 0
# 		}
# 	},
# ]