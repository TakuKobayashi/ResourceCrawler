class CreateDatapoolResourceExtends < ActiveRecord::Migration[5.2]
  def change
    create_table :datapool_resource_extends do |t|

      t.timestamps
    end
  end
end
