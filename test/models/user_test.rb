require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = active_user
  end

  test "name_validation" do
    # 入力必須
    user = User.new(email: "test@example.com", password: "password")
    user.save
    required_msg = ["名前を入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # 最長30文字まで
    max = 30
    name = "a" * (max + 1)
    user.name = name
    user.save
    maxlength_msg = ["名前は#{max}文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 成功
    name = "a" * max
    user.name = name
    assert_difference("User.count", 1) do
      user.save
    end
  end

  test "email_validation" do
    # 入力必須
    user = User.new(name: "test", password: "password")
    user.save
    required_msg = ["メールアドレスを入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # 最長255文字まで
    max = 255
    domain = "@example.com"
    email = "a" * (max + 1 - domain.length) + domain
    assert max < email.length
    user.email = email
    user.save
    maxlength_msg = ["メールアドレスは#{max}文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 間違った書式
    ng_emails = %w(
      aaa.com
      メール@gmail.com
      abc@|gmail.com
      １@ex.com
    )
    ng_emails.each do |email|
      user.email = email
      user.save
      format_msg = ["メールアドレスは不正な値です"]
      assert_equal(format_msg, user.errors.full_messages)
    end

    # 正しい書式
    ok_emails = %w(
      A@A.com
      a-_@e-x.c-o_m.j_p
      a@e.co.jjjo
      1.1@test.co.jp
      fkeasopf@gmail.com
    )
    ok_emails.each do |email|
      user.email = email
      assert user.save
    end

    # メアドの小文字化
    email = "TEST@TEST.COM"
    user = User.new(email: email)
    user.save
    assert user.email = email.downcase

    # アクティブユーザーがいない場合、同じemailが保存できるか
    email = "test@example.com"
    count = 3
    assert_difference("User.count", count) do
      count.times do |n|
        User.create(name: "test", email: email, password: "password")
      end
    end

    # アクティブユーザーがいる場合、同じemailでバリデーションエラーが吐かれるか
    active_user = User.find_by(email: email)
    active_user.update!(activated: true)
    assert active_user.activated

    assert_no_difference("User.count") do
      user = User.new(name: "test", email: email, password: "password")
      user.save
      uniqueness_msg = ["メールアドレスはすでに存在します"]
      assert_equal(uniqueness_msg, user.errors.full_messages)
    end

    # アクティブユーザーがいなくなった場合、同じemailが保存できるようになるか
    active_user.destroy!
    assert_difference("User.count", 1) do
      User.create(name: "test", email: email, password: "password", activated: true)
    end

    # アクティブユーザーのemailの一位性は保たれているか
    assert_equal(1, User.where(email: email, activated: true).count)
  end

  test "password_validation" do
    # 入力必須
    user = User.new(name: "test", email: "test@example.com")
    user.save
    required_msg = ["パスワードを入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # 最短8文字以上
    min = 8
    password = "a" * (min - 1)
    user.password = password
    user.save
    minlength_msg = ["パスワードは#{min}文字以上で入力してください"]
    assert_equal(minlength_msg, user.errors.full_messages)

    # 最長72文字まで
    max = 72
    password = "a" * (max + 1)
    assert max < password.length
    user.password = password
    user.save
    maxlength_msg = ["パスワードは#{max}文字以内で入力してください"]
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 間違った書式
    ng_passwords = %w(
      pass/word
      pass@word
      pass~=?+"'
      １２３４５６７８
    )
    ng_passwords.each do |password|
      user.password = password
      user.save
      format_msg = ["パスワードには半角英数字・ハイフン・アンダーバーが使えます"]
      assert_equal(format_msg, user.errors.full_messages)
    end

    # 正しい書式 VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
    ok_passwords = %w(
      pass---word
      12345678
      -------_
      PASSWORD
    )
    ok_passwords.each do |password|
      user.password = password
      assert user.save
    end
  end
end
