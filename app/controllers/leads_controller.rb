# frozen_string_literal:true

class LeadsController < ApplicationController
  def new
    @lead = Lead.new
  end

  def create
    @lead = Lead.new(lead_params)
    if @lead.save
      redirect_to new_lead_quote_path(@lead)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:first_name, :last_name, :email, :phone_number, :address, :address_2, :zip_code, :city)
  end
end
