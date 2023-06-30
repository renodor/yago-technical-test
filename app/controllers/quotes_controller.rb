# frozen_string_literal:true

class QuotesController < ApplicationController
  def new
    @lead = Lead.find(params[:lead_id])
    @quote = Quote.new
  end

  def create
    @lead = Lead.find(params[:lead_id])
    @quote = Quote.new(quote_params)
    @quote.lead = @lead

    response = InsuranceApi::V1::Client.new.professional_liability(body: @quote.attributes)

    binding.pry
    if @quote.save
      redirect_to quote_path(@quote)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def quote_params
    params
      .require(:quote)
      .permit(
        :annual_revenue, :enterprise_number, :email, :legal_name, :natural_person,
        :coverage_ceiling_formula, :deducible_formula, nacebel_codes: []
      )
  end
end
