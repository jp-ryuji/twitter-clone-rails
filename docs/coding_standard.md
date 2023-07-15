# Coding Standard

The purpose of this standard is to keep code clean, consistent and easier to maintain.

## スタイルガイド（参考）

スタイルガイドへの順守はRuboCopで行うが、参考のため各スタイルガイドへのリンクを載せておく。

- [Ruby Style Guide](https://rubystyle.guide/)
- [Rails Style Guide](https://rails.rubystyle.guide/)
- [RSpec Style Guide](https://rspec.rubystyle.guide/)

## [overcommit](https://github.com/sds/overcommit)

Set up overcommit for git hooks:

```sh
bundle exec overcommit --install
bundle exec overcommit --sign
```

In case you have to ignore hooks:

```sh
SKIP=<hook_command>

e.g. SKIP=RuboCop git commit ...
e.g. OVERCOMMIT_DISABLE=1 git commit ...
```

## [rubocop](https://github.com/rubocop-hq/rubocop)

### 設定

- [Editorにrubocopを組み込む](https://docs.rubocop.org/rubocop/1.53/integration_with_other_tools.html#editor-integration)

- テストのために、Editor内でルールに違反したコードが指摘されること、及びcommit時にそれらのコードがcommit出来ないこと（前述のovercommitが動いていること）を確認する。

- 環境によっては、overcommit and/or rubocop を global にインストールする必要があるかもしれません。その場合、以下を試してください。

```sh
gem install overcommit
gem install rubocop
```

### 運用

- Auto correction

  ```sh
  bundle exec rubocop -A
  ```

- rubocopの設定は適時`.rubocop.yml`を見直して下さい。

- [rubocopの設定を特定の箇所だけ無効にする](https://docs.rubocop.org/rubocop/configuration.html#disabling-cops-within-source-code)

## factory_bot

- [Best practices](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#best-practices)に従う。
  - クラス毎に、最もシンプルなfactoryを1つ定義する。つまり、オブジェクト作成時にバリデーションを通すために必要で、且つデフォルト値を持っていない属性を定義する。
  - カスタマイズしたfactoryは、このfactoryを元に定義する。

- `build` や `create` という形式で呼び出す（`FactoryBot.build` としない）。

## enum

可読性のために、基本的にはstringとする。以下、例。

```ruby
  enum status: {
    active: 'active',
    inactive: 'inactive',
  }
```

## DBカラムのコメント

基本的に不要だが、カラム名からだけでは分かりづらいと思う箇所はcommentを付ける。以下、例。

```ruby
class CreateExampleTables < ActiveRecord::Migration[7.0]
  def change
    create_table :example_tables do |t|
      :
      t.string :column_with_comment, null: false, comment: 'Some Comment'
      :
    end
  end
end
```
