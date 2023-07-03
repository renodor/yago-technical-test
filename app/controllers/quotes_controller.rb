# frozen_string_literal:true

class QuotesController < ApplicationController
  def show
    @quote = Quote.find(params[:id])
  end

  def new
    @lead = Lead.find(params[:lead_id])
    @quote = Quote.new
  end

  def create
    @lead = Lead.find(params[:lead_id])
    @quote = @lead.quotes.new(quote_params)
    response = InsuranceApi::V1::Client.new.professional_liability(body: quote_params.merge(@lead.attributes.slice('nacebel_codes')))

    if response[:success]
      payload = response[:payload]
      payload[:covers].slice!(*params[:covers].map(&:to_sym))

      @quote.update(payload)
      @lead.quoted!
      redirect_to quote_path(@quote)
    else
      @quote.valid? # TODO: explain why
      render :new, status: :unprocessable_entity
    end
  end

  private

  def quote_params
    params
      .require(:quote)
      .permit(:annual_revenue, :enterprise_number, :legal_name, :natural_person, nacebel_codes: [])
  end
end
