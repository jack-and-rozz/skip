Given /^プロフィール画像の変更を許可しないように設定する$/ do
  Given   %!マイページを表示する!
  And     %!"設定・管理"リンクをクリックする!
  And     %!"プロフィール画像の変更を許可する"のチェックを外す!
  And     %!"保存"ボタンをクリックする!
end
