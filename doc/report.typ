#set page(margin: 20mm, numbering: "1 / 1")
#set text(font: "Noto Serif CJK JP", size: 11pt)

#set heading(numbering: "1.1")
#show heading: curr_head => locate(
  loc => {
    let heads = query(selector(heading).before(loc))
    if heads.len() > 1 {
      let prev_head = heads.at(-2)
      if (
        (
          curr_head.location().page() != prev_head.location().page() and curr_head.location().position().y > 60pt
        ) or curr_head.location().position().y - prev_head.location().position().y > 40pt
      ) {
        return [
          #v(1em)
          #curr_head
        ]
      }
    }
    return [#curr_head]
  },
)
#show heading: curr_head => locate(
  loc => {
    let heads = query(selector(heading).after(loc))
    if heads.len() > 0 {
      let next_head = heads.at(0)
      if (
        next_head.location().page() == curr_head.location().page() and next_head.location().position().y - curr_head.location().position().y < 40pt
      ) {
        return [#curr_head]
      }
    }
    return [
      #curr_head
      #par(text(size: 0.5em, ""))
    ]
  },
)

#set par(leading: 1em, justify: true, first-line-indent: 1em)

// #show figure.where(kind: image): set figure(supplement: "Fig. ")
#show figure.where(kind: table): set figure.caption(position: top)

#set math.equation(numbering: "(1)")
#show math.equation: it => h(0.25em, weak: true) + it + h(0.25em, weak: true)
#let trp = $sans(upright(T))$

#v(2em)
#align(center, text(18pt)[*知能機械情報学 課題1*])
#align(center, text[03223008 坂本光皓])
#align(
  center,
  text[#datetime.today().display("[year]年[month padding:none]月[day padding:none]日")],
)
#v(2em)

= 目的

Hopfield Networkを実装し，二値画像を記憶および想起させる実験を行う．

= 理論の概要

== Hopfield Network

Hopfield Networkは全結合型のニューラルネットワークであり，自己想起型と相互想起型に分類される．

自己想起型では全ニューロンにパターン全体を対応させて学習させる．
その後，部分パターンあるいはノイズを含むパターンを入力し，平衡状態となるまで非同期更新を行うことでパターンを想起させる．本課題ではこの形式を用いる．

一方，相互想起型では全ニューロンを入力部，隠れ部，出力部に分けてパターン対を学習させる．
その後，入力部あるいは出力部のみにパターンを入力し，平衡状態となるまで更新を行うことで他方に対応するパターンを想起させる．

$N$個のニューロンに対する重み行列$W in RR^(N times N)$の学習は$Q$個のパターンを用いて次のように行う．
$ W = 1/Q sum_(q=1)^Q bold(x)^((q)) (bold(x)^((q)))^trp, quad w_(i i) = 0 $
ここで，$bold(x)^((q)) in RR^N$は$q$番目の学習パターンを表す．上式から明らかなように$w_(i j) = w_(j i)$である．\
また，時刻$t$においてランダムに選択されたニューロン$i$の出力$x_i$は以下のように更新される．
$ x_i (t+1) = f_i (bold(w)_i^trp bold(x)), quad
f_i (u) = op("sgn")(u-theta_i) = cases(-1 quad & (u-theta_i < 0), 1 & (u-theta_i > 0)) $ <neuron_output>
ただし，$bold(w)_i$はニューロン$i$の結合重み（$W$の$i$列目に対応），$theta_i$はニューロン$i$の閾値を表す．\
平衡状態の判定にはネットワークのエネルギー変化を用いる．エネルギー$V$は
$ V = -1/2 (W bold(x))^trp bold(x) + bold(theta)^trp bold(x) $
とする．直近の一定区間$Delta t$における$V$の最大変化量$Delta V_"max"$が閾値$Delta V_"th"$を下回った場合，収束したとみなし更新を停止する．本課題では$Delta t = 100$，$Delta V_"th" = 1$とした．

#pagebreak()

= 実験方法および結果

@dataset\に実験に使用した二値画像のデータセットを示す．画像は0から5までの数字を5$times$5ピクセルの白背景に黒字で描画したものである．データ上は1で白，-1で黒を表現している．

#figure(grid(
  columns: 6,
  gutter: 5mm,
  image("img/dataset_0.svg", width: 10mm),
  image("img/dataset_1.svg", width: 10mm),
  image("img/dataset_2.svg", width: 10mm),
  image("img/dataset_3.svg", width: 10mm),
  image("img/dataset_4.svg", width: 10mm),
  image("img/dataset_5.svg", width: 10mm),
  "a) 「0」",
  "b) 「1」",
  "c) 「2」",
  "d) 「3」",
  "e) 「4」",
  "f) 「5」",
), caption: [Binary image dataset for experiment], gap: 1em) <dataset>

== 1種類の画像の記憶および想起 <exp_1>

1種類の画像を記憶させ，正解画像にノイズを加えたものを初期値として想起させる実験を行う．本実験では「4」の画像を用い，ノイズの生起確率（以下，ノイズ確率）を5
%，10 %，20
%として1000回想起させる．想起性能の評価には正解画像との類似度の全試行平均，および正答率すなわち正解画像を完全再現した割合を用いる．なお，類似度$c$は次のように定める．
$ c = (bold(x)_"truth"^trp bold(x)) / norm(bold(x)_"truth")^2 $
ここで，$bold(x)_"truth"$は正解パターン，$bold(x)$は想起パターンを表す．

@exp_1_perf\に各ノイズ確率に対する想起性能を示す．ノイズ確率が大きいほど類似度および正答率は低下しているが，いずれの場合も優れた性能が得られているといえる．

#figure(table(
  columns: 3,
  stroke: none,
  inset: (x: 5pt, y: 8pt),
  table.hline(),
  table.header([ノイズ確率], [平均類似度], [正答率]),
  table.hline(stroke: 0.5pt),
  [5 %],
  [0.9995],
  [0.994],
  [10 %],
  [0.9989],
  [0.986],
  [20 %],
  [0.9987],
  [0.985],
  table.hline(),
), caption: [Recall performance]) <exp_1_perf>

#v(1em)
また，@exp_1_hist\にノイズ確率が5 %のときのネットワークの状態推移を示す．$t = 111$でノイズが完全に除去され正解画像を想起できていることがわかる．

#figure(image("img/exp_1_hist_5.png"), caption: [Network state transition]) <exp_1_hist>

#pagebreak()

== 複数種類の画像の想起 <exp_2>

複数種類の画像を記憶させ，正解画像にノイズを加えたものを初期値として想起させる実験を行う．本実験ではノイズ確率を10
%とし，その他の条件は@exp_1\に従う．

@exp_2_perf，@exp_2_perf_graph\に画像の種類数に対する想起性能を示す．画像の種類が増加するほど類似度および正答率が減少し，特に種類数が3になると正答率が大きく低下した．5$times$5ピクセルの解像度では，ノイズを含む3種類以上の数字をHopfield
Networkで判別するのは難しいと考えられる．

#figure(table(
  columns: 4,
  align: (center, left, center, center),
  stroke: none,
  inset: (x: 5pt, y: 8pt),
  table.hline(),
  table.header([画像の種類数], [画像の組], [平均類似度], [正答率]),
  table.hline(stroke: 0.5pt),
  [1],
  [「0」],
  [0.9986],
  [0.983],
  [2],
  [「0」，「1」],
  [0.9989],
  [0.986],
  [3],
  [「0」，「1」，「2」],
  [0.9172],
  [0.338],
  [4],
  [「0」，「1」，「2」，「3」],
  [0.8555],
  [0.166],
  [5],
  [「0」，「1」，「2」，「3」，「4」],
  [0.725],
  [0.002],
  [6],
  [「0」，「1」，「2」，「3」，「4」，「5」],
  [0.7696],
  [0.002],
  table.hline(),
), caption: [Recall performance]) <exp_2_perf>

#v(1em)

#figure(
  image("img/exp_2_perf_graph.png", width: 100mm),
  caption: [Recall performance],
) <exp_2_perf_graph>

== ノイズによる想起性能の変化 <exp_3>

2種類および4種類の画像を記憶させ，正解画像に様々な正規確率のノイズを加えたものを初期値として想起させる実験を行う．本実験では「1」，「3」の2種類の組，および「0」，「2」，「4」，「5」の4種類の組の画像を用い，ノイズ確率を0
%，10 %，20 %，…，100 %とする．その他の条件は@exp_1\に従う．

@exp_3_perf\に各ノイズ確率に対する想起性能を示す．類似度は2種類の場合，4種類の場合のいずれも，ノイズ確率が高くなるにつれ0に近づいている．また，正答率については2種類の場合ノイズ確率が100
%であっても0.3程度であるが，4種類の場合はノイズ確率にかかわらず0付近にとどまっている．これは@exp_2\で得られた結果とも異なるものであり，画像の種類数だけでなく組によっても想起性能が変化すると考えられる．

#figure(
  image("img/exp_3_perf_graph.png", width: 100mm),
  caption: [Recall performance],
) <exp_3_perf>

#v(1em)

次に，ノイズ確率が50 %および100
%のときのネットワークの状態推移を@exp_3_hist_2_50，@exp_3_hist_2_100[]，@exp_3_hist_4_50[]，@exp_3_hist_4_100[]に示す．正解はそれぞれ「3」，「3」，「5」，「2」である．画像が2種類のとき，100
%の場合は想起結果が正解と異なるが，いずれも記憶させた画像を想起できていることがわかる．一方，画像が4種類のときは記憶させていない画像が想起されている．ノイズ確率が50
%を超えると画像の半数以上のピクセルが意味をなさないため，Hopfield
Networkは実質的にノイズから意味のある画像を生成することになる．これは画像生成AIに広く採用されている拡散モデルの逆拡散過程に似ている．

#figure(
  image("img/exp_3_hist_2_50.png", width: 80%),
  caption: [Network state transition (2 image types, 50 % noise)],
) <exp_3_hist_2_50>

#figure(
  image("img/exp_3_hist_2_100.png", width: 80%),
  caption: [Network state transition (2 image types, 100 % noise)],
) <exp_3_hist_2_100>

#figure(
  image("img/exp_3_hist_4_50.png", width: 80%),
  caption: [Network state transition (4 image types, 50 % noise)],
) <exp_3_hist_4_50>

#figure(
  image("img/exp_3_hist_4_100.png", width: 80%),
  caption: [Network state transition (4 image types, 100 % noise)],
) <exp_3_hist_4_100>

== ニューロンの閾値が想起性能に与える影響の分析

@neuron_output\より，各ニューロンの閾値を調整することで特定のパターンに対する正答率を向上させることができると考えられる．本実験では6種類の画像を記憶させ，全ニューロンの閾値を「1」の画像データの$a$倍（$a$：定数）とする．その他の条件は@exp_1\に従う．

$a$を0，1，2，3，5としたときの各画像に対する平均類似度を@exp_4_simil_0，@exp_4_simil_1[]，@exp_4_simil_2[]，@exp_4_simil_3[]，@exp_4_simil_5[]に示す．$a <= 2$のときは「1」に対する類似度が他の画像に比べて低いが，$a >= 3$では2倍以上に増加している．他の画像に対する類似度には有意な変化が見られないため，特定のパターンに対する想起性能のみを改善することができているといえる．

= 感想

今回の課題では，基本的なHopfield
Networkを実装し画像を想起させる実験を行ったことで，ネットワークの原理を実践的に確認することができた．また，ノイズ確率やニューロンの閾値等のパラメータによる想起性能の変化を調べることで，ネットワークの挙動を直感的ではあるが理解できた．

#grid(columns: 2, gutter: 8mm, stroke: none, [#figure(
    image("img/exp_4_simil_0.png", width: 90mm),
    caption: [Image type vs. similarity ($a = 0$)],
  ) <exp_4_simil_0>], [#figure(
    image("img/exp_4_simil_1.png", width: 90mm),
    caption: [Image type vs. similarity ($a = 1$)],
  ) <exp_4_simil_1>], [#figure(
    image("img/exp_4_simil_2.png", width: 90mm),
    caption: [Image type vs. similarity ($a = 2$)],
  ) <exp_4_simil_2>], [#figure(
    image("img/exp_4_simil_3.png", width: 90mm),
    caption: [Image type vs. similarity ($a = 3$)],
  ) <exp_4_simil_3>], grid.cell(colspan: 2, [#figure(
    image("img/exp_4_simil_5.png", width: 90mm),
    caption: [Image type vs. similarity ($a = 5$)],
  ) <exp_4_simil_5>]))
