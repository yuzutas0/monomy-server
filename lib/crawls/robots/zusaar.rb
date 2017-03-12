# encoding: utf-8
class Crawls::Robots::Zusaar

  require 'open-uri'
  require 'kconv'
  require 'json'

  SOURCE_ID = 3

  # rails runner Crawls::Robots::Zusaar.execute
  def self.execute
    puts "Zusaar"

    # loop : yymm (e.g. 201508 - 201512)
    date = Date.today
    for after_month in 0..4

      # loop : start (1, 101, 201, ..., last)
      date_string = (date >> after_month).strftime("%Y%m")
      start_count = 1
      get_count = 10 # todo 100
      loop do

        # HTTP
        request_uri = "http://www.zusaar.com/api/event/?ym=" + date_string + "&count=" + get_count.to_s + "&start=" + start_count.to_s
        response = open(request_uri, &:read).toutf8
        sleep(2)

        # JSON Parse
        json = JSON.parser.new(response)
        hash = json.parse()
        parsed = hash['event']
        break unless parsed.length > 0

        # ready for bulk insert
        insert_list = []

        # loop : event
        parsed.each do |event_inner|
          new_event = Crawls::Converter.get_event(SOURCE_ID, event_inner)

          # find same event
          next if new_event.source_id.blank? || new_event.source_event_id.blank?
          find_event_query = "source_id = :source_id AND source_event_id = :source_event_id"
          old_events = Event.where(find_event_query, source_id: new_event.source_id, source_event_id: new_event.source_event_id)
          old_event = old_events[0] if old_events.present?

          next if new_event.source_updated_at.blank?
          if old_event.present?
            # update
            next if new_event.source_updated_at <= old_event.source_updated_at
            Crawls::Converter.update_event(old_event, new_event)
          else
            # add insert list
            insert_list << new_event
          end
        end

        # bulk insert
        begin
          Event.import(insert_list)
        rescue => e
          puts e.message
        end

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
# http://www.zusaar.com/doc/api.html
# 
#
#
# --------------------------------------------------------------------
# Request Param
# --------------------------------------------------------------------
# http://www.zusaar.com/api/event/?
#
# ym
# => イベント開催年月（例：201103）
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
#
#
# --------------------------------------------------------------------
# Response Param
# --------------------------------------------------------------------
# results_returned（含まれる検索結果の件数）
# => 0になったらページネーション終了
#
# event（複数要素）
# ┣ event_id：イベントID
# ┣ title：タイトル
# ┣ catch：キャッチ => サブタイトルのようなもの
# ┣ description：概要
# ┣ event_url：Zusaar上のURL => イベント詳細ページURL
# ┣ hash_tag：Twitterのハッシュタグ（＊ATNDなし）
# ┣ started_at：イベント開催日時
# ┣ ended_at：イベント終了日時
# ┣ pay_type：無料／有料イベント（＊ATNDなし）
# ┣ url：参考URL
# ┣ limit：定員
# ┣ address：開催場所
# ┣ place：開催会場
# ┣ lat：開催会場の緯度
# ┣ lon：開催会場の経度
# ┣ owner_id：主催者のID
# ┣ owner_profile_url：主催者のプロフィールURL（＊ATNDなし）
# ┣ owner_nickname：管理者のニックネーム
# ┣ accepted：参加者
# ┣ waiting：補欠者
# ┗ updated_at：更新日時 => 取得済みならページネーション終了
#
#
#
# --------------------------------------------------------------------
# http://www.zusaar.com/api/event/
# --------------------------------------------------------------------
# {
# 	"results_start": 1,
# 	"event":
# 	[
# 		{
# 			"limit": 50,
# 			"lon": "",
# 			"owner_nickname": "Kenji Nakagaki",
# 			"waiting": 0,
# 			"catch": "カンボジアの子供たちが使う英語学習アプリを、Androidで作ってみよう！",
# 			"event_id": "9167003",
# 			"url": "https://sites.google.com/a/gtugs.org/tokai/handson/20150802",
# 			"owner_profile_url": "http://www.facebook.com/100002346126273",
# 			"title": "Androidハッカソン「EDUCA x GDG名古屋」",
# 			"updated_at": "2015-07-13T00:39:50Z",
# 			"accepted": 0,
# 			"event_url": "http://www.zusaar.com/event/9167003",
# 			"pay_type": "0",
# 			"address": "",
# 			"description": "<div><font face=\"Arial, Verdana\"><span style=\"font-size: 10pt; line-height: normal;\">EDUCA（ http://class4every1.jp/educa/ ）は、使われなくなったスマートフォンを集めて、そこに英語</span><span style=\"line-height: normal;\">学習アプリ</span><span style=\"font-size: 10pt; line-height: normal;\">をいれてカンボジアの生徒たちに届ける活動をしている、意義ある活動をしている団体です。しかしまだ始まったばかりのプロジェクトなので、いろいろやらなければならないことがあります。その中の一つに、スマートフォンに入れる英語</span><span style=\"line-height: normal;\">学習アプリ</span><span style=\"font-size: 10pt; line-height: normal;\">の改善があります。</span></font></div><div><font face=\"Arial, Verdana\"><span style=\"font-size: 10pt; line-height: normal;\">そこで今回のGDG名古屋では、ハッカソン形式でこの英語</span><span style=\"line-height: normal;\">学習アプリ</span><span style=\"font-size: 10pt; line-height: normal;\">を作ってみたいと思います。ハッカソンの会場には、実際にEDUCAで活動しているメンバーである村田 Andrew 裕亮さん（今は大学一年生で、とてもアクティブな若者です！）にも来ていただいて、EDUCAの活動や用意したい英語</span><span style=\"line-height: normal;\">学習アプリ</span><span style=\"font-size: 10pt; line-height: normal;\">について説明してもらいます。</span></font></div><div style=\"font-family: Arial, Verdana; font-size: 10pt; font-style: normal; font-variant: normal; font-weight: normal; line-height: normal;\"><font face=\"Arial, Verdana\"><span style=\"line-height: normal;\">自分のスキルで世界をちょっと変えてみたいと思っている人たちの参加を、こころよりお待ちしています！</span></font></div>",
# 			"ended_at": "2015-08-02T18:00:00+09:00",
# 			"owner_id": "agxzfnp1c2Fhci1ocmRyHAsSBFVzZXIiEjEwMDAwMjM0NjEyNjI3M19mYgw",
# 			"started_at": "2015-08-02T10:00:00+09:00",
# 			"place": "未定（エイチームで調整中）",
# 			"lat": ""
# 		},
# 		{
# 			"limit": 10,
# 			"lon": 139.7427296,
# 			"owner_nickname": "okachimachiorz1",
# 			"waiting": 0,
# 			"catch": "割と易しい目(推定)の、分散DB本「Principles of Distributed Database Syste",
# 			"event_id": "8047006",
# 			"url": "http://www.nautilus-technologies.com/company/access.html",
# 			"owner_profile_url": "http://twitter.com/okachimachiorz1",
# 			"title": "分散合意本読書会第37回",
# 			"updated_at": "2015-07-09T12:54:39Z",
# 			"accepted": 4,
# 			"event_url": "http://www.zusaar.com/event/8047006",
# 			"pay_type": "0",
# 			"address": "東京都品川区北品川1-19-5 コーストライン品川ビル",
# 			"description": "<div style=\"font-size: 13.3333330154419px;\"><span style=\"font-size: 10pt;\">Fault-Tolerant Agreement in Synchronous Message-Passing Systemsが同期</span></div><div style=\"font-size: 10pt;\"><font style=\"line-height: 13.3333320617676px;\" face=\"Arial, Verdana\"><span style=\"line-height: normal;\">http://www.amazon.co.jp/Fault-Tolerant-Agreement-Synchronous-Message-Passing-Distributed/dp/1608455254/ref=pd_bxgy_fb_text_y</span></font></div><div style=\"font-size: 10pt;\"><font style=\"line-height: 13.3333320617676px;\" face=\"Arial, Verdana\"><span style=\"line-height: normal;\"><br></span></font></div><div style=\"font-size: 10pt;\"><font style=\"line-height: 13.3333320617676px;\" face=\"Arial, Verdana\"><span style=\"line-height: normal;\">Communication and Agreement Abstractions for Fault-Tolerant Distributed Systemsが非同期になります。</span></font></div><div style=\"font-size: 10pt;\"><font style=\"line-height: 13.3333320617676px;\" face=\"Arial, Verdana\"><span style=\"line-height: normal;\">http://www.amazon.co.jp/Communication-Agreement-Abstractions-Fault-Tolerant-Distributed/dp/160845293X/ref=pd_bxgy_fb_text_y</span></font></div><div style=\"font-size: 10pt;\"><font style=\"line-height: 13.3333320617676px;\" face=\"Arial, Verdana\"><span style=\"line-height: normal;\"><br></span></font></div><div style=\"font-size: 10pt;\"><font style=\"line-height: 13.3333320617676px;\" face=\"Arial, Verdana\"><span style=\"line-height: normal;\">合意「だけ」で、こんだけとかどんだけよ、という話ですが、その筋では有名な方の教科書なのでよろしいんじゃないですかね、と言われているで、よろしくやります。</span></font></div><div style=\"font-size: 10pt;\"><font style=\"line-height: 13.3333320617676px;\" face=\"Arial, Verdana\"><span style=\"line-height: normal;\"><br></span></font></div><div style=\"font-size: 10pt;\">非同期本ですね。</div><div style=\"font-size: 10pt;\">「<span style=\"font-size: 13.3333330154419px;\">Communication and Agreement Abstractions for Fault-Tolerant Distributed Systems」ですね・・・・</span></div><div style=\"font-size: 10pt;\"><span style=\"font-size: 13.3333330154419px;\">そもそもRound modelでなくて同期処理とか、どんだけ無理ゲーだよ的な未知との遭遇ですが、こんな本一人で読むとかありえないので、みんなで読みましょう。</span></div><div style=\"font-size: 10pt;\"><br></div><div style=\"font-size: 13.3333330154419px;\"><font style=\"line-height: 13.3333320617676px;\" face=\"Arial, Verdana\"><span style=\"line-height: normal;\">場所は品川です。</span></font></div>",
# 			"ended_at": "2015-07-22T21:00:00+09:00",
# 			"owner_id": "agxzfnp1c2Fhci1ocmRyFgsSBFVzZXIiDDE3MDQ1NzA3Nl90dww",
# 			"started_at": "2015-07-22T19:00:00+09:00",
# 			"place": "ノーチラス・テクノロジーズ",
# 			"lat": 35.6235592
# 		}
# 	],
# 	"results_returned": 10
# }