# RC Pro Quotes

## Built with:
- Ruby 3.2.2
- Rails 7.0.4
- PostgreSQL

<br />

- [Tailwindcss](https://tailwindcss.com/) for CSS
- [Rspec](https://rspec.info/) for testing
- [Simple Form](https://github.com/heartcombo/simple_form) for HTML forms
- [Faraday](https://github.com/lostisland/faraday) for HTTP client
- [Docker](https://docs.docker.com/) for containerization

## Setup
Make sure you have [Docker Engine](https://docs.docker.com/engine/install/) installed on your local machine. Then follow this steps to setup the app on your local machine:

1. `git clone git@github.com:renodor/rc_pro_quotes.git && cd rc_pro_quotes`, to clone this repo to your local machine and navigate to the repo directory
2. `rails_master_key`: `echo 'RAILS_MASTER_KEY={{rails_master_key}}' > .env`, to create an `.env` file with the `RAILS_MASTER_KEY` environment variable. (Replace `{{rails_master_key}}` by the key given to you by email)
3. `docker compose build && docker compose run web rails db:prepare`, to build Docker images and prepare Rails database. This may take a few minute to download Docker images install dependencies and gems
4. `docker compose up`, to start Docker containers and access the app on `localhost:3000`
5. (`docker compose down`, to stop Docker containers)

<br />

You can also run any Rails commands with `docker compose run web {{rails command}}`. Ex:
- `docker compose run web rails c`
- `docker compose run web rails db:reset`
- etc...

## Credentials
- The app uses [Rails credentials](https://edgeguides.rubyonrails.org/security.html#custom-credentials) to store secrets
- In order to work properly the app needs to read the credentials stored in `config/credentials.yml.enc`
- For that please make sure that your repo has an `.env` file with the valid `RAILS_MASTER_KEY` variable in it.

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

### Pages
The current version of the App has 3 pages with the following user journey:
1. Home page: A form to get lead contact informations. With a CTA to go to quote form.
2. Quote form: A form to get quote information, and advice user on the best options regarding his/her profile. With a CTA to create quote.
3. Quote page: displays newly created RC quote.

### Specs
- Run Rspec specs with `docker compose run web bundle exec rspec`
We currently only have model specs (to test `Lead` and `Quote` models), and service spec (to test `InsuranceApi::V1::Client`). Going further we would need to create integration specs to test the user journey into the different pages.

