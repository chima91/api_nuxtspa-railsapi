class User < ApplicationRecord
  # bcrypt gem の メソッド（新規登録時のみパスワード入力必須を検証する）
  has_secure_password

  validates :name, presence: true,
                    length: {
                      maximum: 30,
                      # 入力が空白の場合にはエラーを出さない
                      allow_blank: true
                    }

  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  validates :password, presence: true,
                        length: {
                          minimum: 8,
                          allow_blank: true
                        },
                        format: {
                          with: VALID_PASSWORD_REGEX,
                          message: :invalid_password,
                          allow_blank: true
                        },
                        # name属性のみ更新する場合などにエラーとならないために設定する
                        allow_nil: true
end
