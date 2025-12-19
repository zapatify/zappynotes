class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :notebook, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.integer :content_size
      t.integer :position

      t.timestamps
    end
  end
end
