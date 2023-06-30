class RenameQuoteColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :quotes, :coverage_ceiling, :coverage_ceiling_formula
    rename_column :quotes, :deducible, :deducible_formula
  end
end
