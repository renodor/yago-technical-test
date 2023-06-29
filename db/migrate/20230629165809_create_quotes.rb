class CreateQuotes < ActiveRecord::Migration[7.0]
  def change
    create_table :quotes do |t|
      t.integer :annual_revenue, null: false
      t.string :enterprise_number, null: false
      t.string :legal_name, null: false
      t.boolean :natural_person, null: false, default: true
      t.string :nacebel_codes, null: :false, array: true, default: []
      t.integer :coverage_ceiling
      t.integer :deducible
      t.float :after_delivery
      t.float :public_liability
      t.float :professional_indemnity
      t.float :entrusted_objects
      t.float :legal_expenses

      t.references :lead, foreign_key: true, null: false

      t.timestamps
    end
  end
end
