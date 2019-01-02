class CreateDatapoolKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_keywords do |t|
      t.string :keyword, null: false
      t.string :uuid, null: false
      t.integer :used_count, null: false, default: 0
      t.text :options
      t.timestamps
    end
    add_index :datapool_keywords, :keyword, unique: true
    add_index :datapool_keywords, :uuid, unique: true
  end
end
