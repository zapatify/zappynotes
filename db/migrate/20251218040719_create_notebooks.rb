class CreateNotebooks < ActiveRecord::Migration[8.1]
  def change
    create_table :notebooks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :color
      t.integer :position

      t.timestamps
    end
  end
end
