# imi-assignment-1

知能機械情報学レポート課題1

## 実行環境
- Windows 11
- Python 3.12.0 (@ rye 0.33.0)

## 実行方法
1. rye等で仮想環境を作成
```
$ cd imi_assignment_1
$ rye sync                           # ryeが使用可能な場合
$ pip install -r requirements.lock   # その他
```
2. モジュールを実行
```
# ryeが使用可能な場合
$ rye run python -m imi_assignment_1

# その他
$ python -m imi_assignment_1
```

# プログラムについて
- `__main__.py`：メイン処理
- `data_loader.py`：データセットの読み込み，ランダム選択等
- `hopfield_network.py`：Hopfield Networkの実装
- `transforms.py`：ランダムノイズの付加