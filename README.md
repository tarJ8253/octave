# Octaveを用いたサンプルプログラムです。

./oct_gui/にはGUIを用いたサンプルが、
./control/には二次標準形式のシステム応答を示すサンプルがあります。

## 内容

|ファイル名|概要|
|:------------------|:----------------------|
| oct_gui/oct_gui_sample.m   | OctaveのGUIを用いたサンプル                 |
| control/b2_control_step1.m | 周波数領域で用いる項目の例                   |
| control/pid_sim.m          | PID制御のシミュレーション。PIDゲインを自分で設定します         |
| control/pole_clk.m         | 複素平面上の極位置を指定すると、その極位置でのステップ応答を示します。 |
| control/pole_slide.m       | 極位置をスライダで動かし、その極位置での時間応答を示します。         |
| control/sys2d_step.m       | 減衰係数と固有角周波数を動かしたときの時間応答                         |
| control/sys2d_step_pole.m  | 時間応答と極位置の関係を表示します                                     |

## 動作確認環境
- debian12,13:  Octave 9
- Windows 10,11:  Octave 9,10

NO WARRANTY.無保証です。
自己責任でご使用ください。
