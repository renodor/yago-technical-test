class CreateLeads < ActiveRecord::Migration[7.0]
  def change
    create_table :leads do |t|
      t.string :email, null: false
      t.string :phone_number, null: false
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :address_2
      t.string :zip_code
      t.string :city
      t.string :nacebel_codes, null: :false, array: true, default: []
      t.integer :activity, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
