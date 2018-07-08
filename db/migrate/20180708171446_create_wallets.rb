class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.string :name, limit: 64
      t.string :currency, limit: 5
      t.string :address
      t.string :type, limit: 32
      t.integer :nsig
      t.integer :parent
      t.string :status, null: true, limit: 32

      t.timestamps null: false
    end
  end
end
