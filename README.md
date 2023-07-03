# RC Pro Quotes

## Built with:
- Ruby 3.2.2
- Rails 7.0.4
- PostgreSQL

## Other dependencies
- [Tailwindcss](https://tailwindcss.com/) for CSS
- [Rspec](https://rspec.info/) for testing
- [Simple Form](https://github.com/heartcombo/simple_form) for HTML forms
- [Faraday](https://github.com/lostisland/faraday) for HTTP client

## Setup
- `bundle install` to install dependencies
- `rails db:create` to create the Databse
- `rails db:migrate` to run migrations
- `bin/dev` to launch dev server on `localhost:3000`

- `bundle exec rspec` to run the specs

## App Structure
### Models
#### Lead
Store potential customers contact information.
Leads are meant to be re-contacted by the commercial team in order be converted to customers.
Every lead have at least an `email` a `phone_number` and some NACE-BEL codes.
Every lead also have a `status` (`initial`, `quoted`, `contacted`, `customer`, `closed`) in order to follow along its commercial journey.
Lead can have some associated `quotes`.

#### Quote
Store insurance quotes requested by our leads.
Every `quote` belongs to a specific `lead`.
To create a `quote` we get some of our lead information (NACE-BEL codes, `annual_revenue`, `enterprise_number`, `coverage_ceiling_formula`, `deductible_formula`),
and then call the Insurance API (`https://staging-gtw.seraphin.be/quotes/`) to get the `coverage_ceiling`, `deductible` and `covers` prices.

### Services
#### Insurance Api
The `InsuranceApi::V1::Client` service is used to call the Insurance Api: `https://staging-gtw.seraphin.be/quotes/`
Currently only used to call the `professional-liability` endpoint.

### Pages
The current version of the App has 3 pages. The user flow is the following:
1. Home page: A form to get lead contact informations
2. Quote form: A form to get quote information, and advice user on the best options regarding his/her profile
3. Quote page: displays newly created RC quote

