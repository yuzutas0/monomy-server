# encoding: utf-8
class Crawls::Robots::Connpass

	require 'open-uri'
	require 'kconv'
	require 'json'

	# rails runner Crawls::Robots::Connpass.execute
	def self.execute
		puts "Connpass"
	end

end





# --------------------------------------------------------------------
# Document
# --------------------------------------------------------------------
# http://connpass.com/about/api/
# 
#
#
# --------------------------------------------------------------------
# Request Param
# --------------------------------------------------------------------
# http://connpass.com/api/v1/event/?
#
# ym
# => イベント開催年月（例：201204）
# => 実際に投げるクエリは現在＋5ヶ月分（例：201507から201512）
#
# start
# => 検索の開始位置（初期値：1）
# => 実際に投げるクエリは1,101,201...
#
# order
# => 検索結果の表示順（1: 更新日時順、2: 開催日時順、3: 新着順）（初期値: 1）
# => 実際に投げるクエリは1
# 
# count
# => 取得件数（初期値：10、最小値：1、最大値：100）
# => 実際に投げるクエリは100
#
#
#
# --------------------------------------------------------------------
# Response Param
# --------------------------------------------------------------------
# results_returned（含まれる検索結果の件数）
# => 0になったらページネーション終了
#
# events（複数要素）
# ┣ event_id：イベントID
# ┣ title：タイトル
# ┣ catch：キャッチ => サブタイトルのようなもの
# ┣ description：概要
# ┣ event_url：connpass.com上のURL => イベント詳細ページURL
# ┣ hash_tag：Twitterのハッシュタグ（＊ATNDなし）
# ┣ started_at：イベント開催日時
# ┣ ended_at：イベント終了日時
# ┣ limit：定員
# ┣ event_type：イベント参加タイプ（参加受付/告知のみ）（＊ATNDなし）
# ┗ series：グループ（＊ATNDなし）
# 	┣ id：グループID
# 	┣ title：グループタイトル
# 	┗ url：グループのconnpass.com上のURL
# ┣ address：開催場所
# ┣ place：開催会場
# ┣ lat：開催会場の緯度
# ┣ lon：開催会場の経度
# ┣ owner_id：管理者のID
# ┣ owner_nickname：管理者のニックネーム
# ┣ owner_display_name：管理者の表示名（＊ATNDなし）
# ┣ accepted：参加者数
# ┣ waiting：補欠者数
# ┗ updated_at：更新日時 => 取得済みならページネーション終了
#
#
# 
# --------------------------------------------------------------------
# http://connpass.com/api/v1/event/
# --------------------------------------------------------------------
# AFTER UTF-16 DECODE
# --------------------------------------------------------------------
# {
# 	"results_returned": 10,
# 	"events":
# 	[
# 		{
# 			"event_url": "http://connpass.com/event/17124/",
# 			"event_type": "participation",
# 			"owner_nickname": "7shi",
# 			"series":
# 			{
# 				"url": "http://connpass.com/series/182/",
# 				"id": 182,
# 				"title": "池袋バイナリ勉強会"
# 			},
# 			"updated_at": "2015-07-13T09:21:05+09:00",
# 			"lat": "35.732527800000",
# 			"started_at": "2015-07-20T13:00:00+09:00",
# 			"hash_tag": "ikebin",
# 			"title": "【中止】池袋バイナリ勉強会(85)",
# 			"event_id": 17124,
# 			"lon": "139.707230600000",
# 			"waiting": 0,
# 			"limit": 18,
# 			"owner_id": 4865,
# 			"owner_display_name": "7shi",
# 			"description": "<p><font color=\"red\" size=\"+2\"><strong>参加者が少ないため中止しました。</strong></font></p>\n<hr>\n<p><strike>\n適当に集まって、適当にもくもくやる会です。</strike></p><strike>\n<p>発表するときもあれば、しないこともあります。</p>\n<p>今までの内容については<a href=\"https://bitbucket.org/7shi/ikebin/wiki/history\" rel=\"nofollow\">開催履歴</a>をご参照ください。</p>\n<h1>その他</h1>\n<p>この会場で開催される他の勉強会については以下をご参照ください。</p>\n</strike><ul><strike>\n</strike><li><strike><a href=\"https://bitbucket.org/7shi/ikebin/wiki/sched\" rel=\"nofollow\">池袋バイナリ勉強会スケジュール</a>\n  （<a href=\"https://sharing.calendar.live.com/calendar/private/bccab7d2-37e5-43a3-a1e0-ef1e93e08323/a4ae57ac-7f35-4548-ba54-605603c7a592/cid-fb45e1f8ce8b532e/index.html\" rel=\"nofollow\">カレンダー</a>）\n</strike></li>\n</ul>",
# 			"address": "東京都豊島区池袋 2-12-11 (三共池袋ビル 4階 401号室)",
# 			"catch": "",
# 			"accepted": 0,
# 			"ended_at": "2015-07-20T18:00:00+09:00",
# 			"place": "池袋バイナリ勉強会"
# 		},
# 		{
# 			"event_url": "http://shibuya-java.connpass.com/event/16867/",
# 			"event_type": "participation",
# 			"owner_nickname": "seri_k",
# 			"series": {
# 				"url": "http://shibuya-java.connpass.com/",
# 				"id": 520,
# 				"title": "渋谷java"
# 			},
# 			"updated_at": "2015-07-13T08:42:10+09:00",
# 			"lat": "35.658774900000",
# 			"started_at": "2015-08-01T14:00:00+09:00",
# 			"hash_tag": "渋谷java",
# 			"title": "第十二回 #渋谷java",
# 			"event_id": 16867,
# 			"lon": "139.705222800000",
# 			"waiting": 0,
# 			"limit": 10,
# 			"owner_id": 7946,
# 			"owner_display_name": "seri_k",
# 			"description": "<h2>javaに関することなら何でもありのゆるふわjava LTイベントです。</h2>\n<ul>\n<li>参加される方はSIerの方や自社プロダクト開発の方やフリーランスの方など様々です</li>\n<li>LTの内容は 初心者向け～ガチ勢向けまで幅広く実施して頂いておりますので初心者の方もモヒカンの方お気軽にどうぞ！</li>\n</ul>\n<p><a href=\"http://togetter.com/t/%E6%B8%8B%E8%B0%B7java\" rel=\"nofollow\">過去の開催分togetter 一覧</a></p>\n<p>ハッシュタグ： <a href=\"https://twitter.com/hashtag/%E6%B8%8B%E8%B0%B7java?src=hash\" rel=\"nofollow\">#渋谷java</a></p>\n<h2>参加受付について</h2>\n<ul>\n<li>今回から<strong>スピーカー枠と観覧者枠の受付期間を分けます</strong></li>\n<li>現在はスピーカー枠のみ受付しております</li>\n</ul>\n<h3>スピーカー枠</h3>\n<h4>受付期間</h4>\n<ul>\n<li><strong>7/1 0:00～イベント当日</strong></li>\n</ul>\n<h4>募集人数</h4>\n<ul>\n<li>LT枠 7人</li>\n<li>セッション枠 3人</li>\n</ul>\n<h3>観覧者枠</h3>\n<h4>受付期間</h4>\n<ul>\n<li><strong>7月中旬～イベント当日</strong></li>\n</ul>\n<h4>募集人数</h4>\n<ul>\n<li>30人</li>\n</ul>\n<h1>会場案内</h1>\n<h2>場所</h2>\n<ul>\n<li>株式会社ビズリーチ</li>\n<li>東京都渋谷区渋썲-15-1 渋谷クロスタワ섯</li>\n</ul>\n<h2>会場概要</h2>\n<ul>\n<li>当日漓:30頃開場です</li>\n<li>wi-fiはあります</li>\n<li>電源は数に限りがあります</li>\n<li>トイレはあります</li>\n</ul>\n<h1>LT募集</h1>\n<ul>\n<li>持ち時間はセッションꀠ分、通常ꀐ分です</li>\n<li>LTご希望の方はコメント欄にてLTのタイトルを一緒に記述ください</li>\n<li>セッション枠・通常枠含めて最大１０名LTスピーカーを募集します</li>\n<li>先着順とします</li>\n</ul>\n<h1>注意事項</h1>\n<ul>\n<li>質疑応答は時間が余っていた場合の実施しますが時間がなければ後で本人に突撃してく下さい</li>\n<li>最近白熱しすぎて時間を過ぎてしまう方が続出しているので時間を守って楽しくLTしましょう</li>\n</ul>\n<h1>LT一覧(敬称略)</h1>\n<h2>セッション枠ࠠ分)</h2>\n<ul>\n<li>ayato_p 「ネタじゃない ClojureScript」</li>\n<li>k.hasunuma 「GlassFish Internals #2 : Modular Architecture」</li>\n<li>making 「どこよりも早い Spring Boot 1.3 解説」</li>\n</ul>\n<h2>通常枠ࠐ分）</h2>\n<ul>\n<li>hajimeni 「タイトル未定」(AWS Lamdaを使って何か発表)</li>\n<li>bati11 「Spring Boot と Swagger」</li>\n<li>nikuyoshi 「Javaの資格試験(OCJ-P)を取って何を学んだか｣</li>\n<li>unknown_199309 「タイトル未定」</li>\n<li>zer0_u 「古いJavaから新しいJavaへ年目の挑戦」</li>\n<li>y_taka_23 「タイトル未定」(Java の型システムの形式化について)</li>\n<li>fmnb0516 「Nashornを使ったSinatra風アプリケーションの実装」</li>\n</ul>",
#				"address": "東京都渋谷区渋썲-15-1 (渋谷クロスタワ섯)",
# 			"catch": "スピーカー募汧/1開始　観覧枠募汧月中旬開始",
# 			"accepted": 10,
# 			"ended_at": "2015-08-01T17:00:00+09:00",
# 			"place": "株式会社ビズリーチ"
# 		}
# 	],
# 	"results_start": 1,
# 	"results_available": 7788
# }