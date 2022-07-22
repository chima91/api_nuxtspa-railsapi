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
  end
end
