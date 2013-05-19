class AddMnemonicToSports < ActiveRecord::Migration
  def change
    add_column :sports, :mnemonic, :string
  end
  def down
    remove_column :sports, :mnemonic
  end
end
