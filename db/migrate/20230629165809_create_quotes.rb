class CreateQuotes < ActiveRecord::Migration[7.0]
  def change
    create_table :quotes do |t|
      t.integer :annual_revenue, null: false
      t.string :enterprise_number, null: false
      t.string :legal_name, null: false
      t.boolean :natural_person, null: false, default: true
      t.integer :coverage_ceiling
      t.integer :deductible
      t.jsonb :covers, null: :false, default: {}

      t.references :lead, foreign_key: true, null: false

      t.timestamps
    end
  end
end
