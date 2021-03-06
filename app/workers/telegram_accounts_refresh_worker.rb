class TelegramAccountsRefreshWorker
  include Sidekiq::Worker

  sidekiq_options queue: :telegram

  def perform
    TelegramAccount.where.not(telegram_id: nil).find_each do |account|
      RedmineBots::Telegram::Tdlib::GetUser.(account.telegram_id).then do |user|
        ActiveRecord::Base.connection_pool.with_connection do
          account.update_attributes(user.to_h.slice(*%w[username first_name last_name]))
        end
      end.wait
    end
  end
end
