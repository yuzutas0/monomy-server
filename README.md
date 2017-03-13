# 概要

IT系勉強会まとめアプリ

# 構成

* [d]app
  * [d]controllers
  * [d]models
* [d]lib
	* [d]crawls：取得用バッチ
		* [d]robots：各サイトからの取得処理
			* atnd：ATNDから取得
			* connpass：Connpassから取得
			* zusaar：Zusaarから取得
			* doorkeeper：DoorKeeperから取得
		* converter.rb：データを整形してサイト間の差異を調整する
		* manager.rb：各処理を管理する大元（このスクリプトが実際に呼ばれる）
	* learnings：機械学習用バッチ[WIP]
