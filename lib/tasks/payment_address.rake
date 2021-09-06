# frozen_string_literal: true

namespace :payment_address do
  desc 'Export payment addresses with non zero balances'
  task :export, %i[gateway blockchain_key] => [:environment] do |_, args|
    file = "#{Rails.root}/addresses.txt"
    File.open(file, 'w') do |f|
      Wallet.where(gateway: args.gateway, blockchain_key: args.blockchain_key).each do |w|
        PaymentAddress.where(wallet_id: w.id).where.not(address: nil).find_in_batches(batch_size: 100) do |group|
          group.each do |pa|
            balances = Account.where(member_id: pa.member_id, currency_id: w.currencies)
                              .select { |a| a.balance > 0 || a.locked > 0}
            f.write("#{a.address}\n") if balances.present?
          end
          sleep(0.1)
        end
      end
    end
  end
end
