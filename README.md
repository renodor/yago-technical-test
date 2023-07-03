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
- Stores potential customers contact informations
- Leads are meant to be re-contacted by the commercial team in order be converted to customers
- Every `lead` has at least an `email` a `phone_number` and some `nacebel_codes` (NACE-BEL codes)
- Every `lead` also has a `status` (`initial`, `quoted`, `contacted`, `customer`, `closed`) in order to follow along its commercial journey
- `lead` can have some associated quotes

#### Quote
- Stores insurance quotes requested by leads
- Every `quote` belongs to a specific `lead`
- To create a `quote` we get some user information (`nacebel_codes`, `annual_revenue`, `enterprise_number`, `legal_name`, `person_type`, `coverage_ceiling_formula`, `deductible_formula`), and then call the Insurance API to get the `coverage_ceiling`, `deductible` and `covers` prices

### Services
#### Insurance Api
- The `InsuranceApi::V1::Client` service is used to call the Insurance Api: `https://staging-gtw.seraphin.be/quotes/`
- Currently only used to call the `professional-liability` endpoint
- (Please contact an administrator to get a valid Api key for authentication)

### Pages
The current version of the App has 3 pages with the following user journey:
1. Home page: A form to get lead contact informations. With a CTA to go to quote form.
2. Quote form: A form to get quote information, and advice user on the best options regarding his/her profile. With a CTA to create quote.
3. Quote page: displays newly created RC quote.

### About Specs
We currently only have model specs (to test `Lead` and `Quote` models), and service spec (to test `InsuranceApi::V1::Client`). Going further we would need to create integration specs to test the user journey into the different pages.

