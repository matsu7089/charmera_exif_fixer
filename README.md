# Charmera Exif Fixer

写真のExifデータに含まれる日時フォーマットを修正し、必要に応じてメーカー名やモデル名を書き換えるFlutterユーティリティアプリです。
Kodak Charmeraで撮影した写真の不正な日時フォーマット（`YYYY:MM:DD:HH:MM:SS`）を持つ画像ファイルを、標準的な `YYYY:MM:DD HH:MM:SS` 形式に修正して保存し直します。

## 機能

- **Exif日時フォーマットの修正**: 標準的な `YYYY:MM:DD HH:MM:SS` 形式に修正します。
- **メーカー・モデル名の変更**: Exifデータの `Make`（メーカー名）および `Model`（モデル名）を任意の文字列に書き換えることができます。
- **フォルダ一括処理**: 指定した入力フォルダ内の画像（jpg, jpeg, heic）をスキャンし、修正したファイルを出力フォルダに保存します。
- **Android Scoped Storage対応**: Androidのセキュリティ要件（Scoped Storage）に準拠したファイルアクセスを行います。

## セットアップ方法

### 前提条件

- Flutter SDK (3.10.8以上)
- Android開発環境 (Android Studio, Android SDK)

### インストールと実行

1. プロジェクトのディレクトリに移動します。
2. 依存パッケージをインストールします。

```bash
flutter pub get
```

3. アプリを実行します。

```bash
flutter run
```

## 使い方

1. **Input Folder**: 「Select Input Folder」ボタンを押し、修正対象の画像が保存されているフォルダを選択します。
2. **Output Folder**: 「Select Output Folder」ボタンを押し、修正後のファイルを保存する空のフォルダなどを選択します。
3. **App Settings (Optional)**:
    - **Camera Maker**: 必要に応じてカメラのメーカー名を入力します。
    - **Camera Model Name**: 必要に応じてカメラのモデル名を入力します。
4. **Start Processing**: 「Start Processing」ボタンを押すと処理が開始されます。進捗状況が表示され、完了すると結果ダイアログが表示されます。
