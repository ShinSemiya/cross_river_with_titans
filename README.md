CodeIQの以下の問題を解いた
https://codeiq.jp/ace/joboffer_apli/q419

問題内容
■兵士が巨人に食べられることなく、右の川岸から左の川岸に渡る順番を書いてください。
・「SSSTTT/」でスタートし、「/SSSTTT」で終了します。
・川を1回渡るごとに1行書き、改行してください。
・兵士が巨人に食べられたり、あるいはちゃんと全員が川を渡りきれなかったりすると不正解となります。
・複数解答ある場合は「解答1」「解答2」とそれぞれの順番の最初に書いてください。

■問題文
3人の兵士と3体の巨人がルビコン川を渡ろうとしています。
川を渡るには、2人乗りの1艘の船を使うしか方法がありません。

兵士も巨人も同じ強さで、双方が同じ数、もしくは兵士の数が多いとパワーバランスが保てるのですが、
巨人が兵士の数より多いと、巨人は兵士を食べてしまいます。

兵士が巨人に食べられることなく、全員がルビコン川を渡るにはどうしたらよいでしょうか？

兵士はS(Soldier)、巨人はT（Titan）とあらわすことにします。

最初は全員左側の川岸にいるので、

    SSSTTT/


となります。巨人に食べられることなく、川を渡るため、まず最初に巨人から移動することにします。

    SSST/TT


船をまた戻さないといけないので、1体だけ巨人を戻します。

    SSSTT/T


次に川を渡るため、今回も巨人を移動させるとします。

    SSS/TTT


このようにして川を渡っている様子を表記します。
上記のいずれも巨人は兵士を食べませんが、以下のような状態になると、兵士は食べられてしまうので、ご注意ください。

    STT/SST
    ↑
    食べられてしまう兵士


最終的には以下のように全員が右側の川岸に渡りたいです。

    /SSSTTT


さて兵士が食べられることなく、無事に川を渡るにはどうしたらよいでしょうか。

プログラミング言語はRubyを使って考えてみてください。


========================================
せみやが考えたアバウトな流れ
【右向き】
1. payload(乗客数) を決める
2. 人数比(titanの人数)を決める
3. その人数を載せて運行して大丈夫か？(s, t)==1か？チェック
   is_ok?
4. 左岸到着時の位置は往復前に比べて前進しているか？
   (前回きた人数がそのまま対岸に引き返していないか？)
5. 記録取る
6. 運ぶ
【左向き】
1. payload(乗客数) を決める
2. 人数比(titanの人数を決める)
3. その人数を載せて運行して大丈夫か？(s, t)==1か？チェック
   is_ok?
4. 右岸到着時の位置は往復前に比べて前進しているか？
5. 記録取る
6. 運ぶ

