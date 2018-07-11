class CreateBlockchains < ActiveRecord::Migration
  def change
    create_table :blockchains do |t|
      t.string  :key,                 null: false, index: { unique: true }
      t.string  :name
      t.string  :client
      t.string  :server
      t.integer :height
      t.string  :explorer_address
      t.string  :explorer_transaction
      t.string  :status,              index: true
      t.boolean :case_sensitive,      null: false, default: true

      t.timestamps null: false
    end

    add_column :currencies, :blockchain_key, :string, limit: 32, first: true
  end
end
