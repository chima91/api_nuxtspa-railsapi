# コンソール起動時
if defined? Rails::Console
  # Hirbの有効化
  Hirb.enable if defined? Hirb
end
