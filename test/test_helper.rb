ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # seedデータの読み込み
    load "#{Rails.root}/db/seeds.rb"
  end

  # :number_of_processors -> 使用しているマシン(今回はDocker)のコア数 -> 4
  parallelize(workers: :number_of_processors)

  # アクティブユーザーを返す
  def active_user
    User.find_by(activated: true)
  end
end
