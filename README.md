# verilog-kenpuro

東工大研究プロジェクト（吉瀬研究室）のgit

## 概要
タイミングゲームの実装

## 用いたハードウエア
- Nexys 4 DDA
- VGA モニタ
- Verilog

## コードの説明

ざっくりとしたフローチャートを下に示す。タイミングは微妙に異なる。

![Flow chart](https://raw.githubusercontent.com/sff1019/verilog-kenpuro/master/diagram.png)

### VGA出力
吉瀬先生のコードを参考にした。  
追加で、どこを描いているのかがわかるようにx,y座標を追加した。

### BRAM実装

### 図形出力

### 経過時間計算

### ポイント実装

ポイントは最大10000000点、その後は下記のような計算とした。  
`10000000 - 面積 - 10000 * 経過時間`

## 参考サイト

https://timetoexplore.net/
