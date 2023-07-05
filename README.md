# RC Pro Quotes

## Built with:
- Ruby 3.2.2
- Rails 7.0.4
- PostgreSQL

<br />

- [Tailwindcss](https://tailwindcss.com/) for CSS: perfect tool to quickly add simple design to an MVP
- [Rspec](https://rspec.info/) for testing: the go-to testing library for Rails
- [Simple Form](https://github.com/heartcombo/simple_form) for HTML forms: awesome tool to easily render forms with model data and error binding
- [Faraday](https://github.com/lostisland/faraday) for HTTP client: gives a simple and easy interface to make HTTP requests to consume Apis
- [Docker](https://docs.docker.com/) for containerization

## Setup
Make sure you have [Docker Engine](https://docs.docker.com/engine/install/) installed on your local machine, then follow this steps to setup the app:

1. `git clone git@github.com:renodor/rc_pro_quotes.git && cd rc_pro_quotes` : clone this repo to your local machine and navigate to the repo directory
2. `echo 'RAILS_MASTER_KEY={{rails_master_key}}' > .env` : create an `.env` file with the `RAILS_MASTER_KEY` environment variable. (Replace `{{rails_master_key}}` by the key given to you by email)
3. `docker compose build && docker compose run web rails db:prepare` : build Docker images and prepare Rails database. This may take a few minutes to download Docker images, install dependencies and gems
4. `docker compose up` : start Docker containers and access the app on `localhost:3000`
5. (`docker compose down` : stop Docker containers)

<br />

You can also run any Rails commands with `docker compose run web {{rails command}}`. Ex:
- `docker compose run web rails c`
- `docker compose run web rails db:reset`
- etc...

## Credentials
The app uses [Rails credentials](https://edgeguides.rubyonrails.org/security.html#custom-credentials) to store secrets. \
In order to work properly the app needs to read the credentials stored in `config/credentials.yml.enc`. \
For that please make sure that your repo has an `.env` file with the valid `RAILS_MASTER_KEY` variable in it. (This should be ok if you followed step 2 of setup process)

## Specs
Run Rspec specs with `docker compose run web bundle exec rspec`

## App Structure

The goals of the RC Pro app are:
1. to collect commercial leads
2. to propose RC Pro quotes to users (generated thanks to an Insurance Api)

Design-wise we then decided to have:
- a `Lead` model, to store leads data
- a `Quote` model, to store quotes data
- an `InsuranceApi` service, to consume the Insurance Api

### Models
#### Lead
- Stores contact informations of potential customers
- Leads are meant to be re-contacted by the commercial team in order to be converted to customers
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

### User journey
The current version of the App has 3 pages with the following user journey:
1. Home page: A form to get lead contact informations. With a CTA to go to quote form.
2. Quote form: A form to get quote information, and advice user on the best options regarding his/her profile. With a CTA to create quote.
3. Quote page: displays newly created RC quote.


## Limitations & To Do's
### Design decisions
The current version of the app has two models: `Lead` and `Quote`, and one `InsuranceApi` service to call the Insurance Api. At first, the idea was simple:
- Attributes related to the user profile and that don't have an influence on the quote should go into the `Lead` model (things like `email`, `phone_number`, `first_name`, `last_name`, `address` etc..)
- Attributes that have an influence on the quote, that are part of the quote itself or needed to call the Insurance Api should go into the `Quote` model (things like `annual_revenue`, `coverage_ceiling`, `deductible` etc...)

But then the distinction appeared not so obvious:
- `enterprise_number` and `legal_name` are more related to the user profile, and shouldn't influence the quote in any ways, but are needed to call the Insurance Api and generate a quote
- `nacebel_codes` (NACE-BEL codes) and `person_type` (natural person or not), can influence the quote but can also be considered as "user profile" attributes

So where to store those attributes? On the `Lead` or `Quote` model? \
Overall the decision taken was to stay as close as possible to the Insurance Api: all attributes needed to consume the Api will go in the `Quote` model. Considering that this model stores quotes generated by this Api.

This also helps to reduce the size of the lead creation form (the app home page), which makes it more digest and helps to generate more leads. (Which is the underlying main goal of the app).

The only exception is the `nacebel_codes` attribute: it belongs to `Lead` model, whereas it is needed to consume the Insurance Api. This is because we need those NACE-BEL codes to define the user `activity` to then generate advises on the quote form (what deductible formula, coverage ceiling formula and covers is best for his/her profile). So it was way easier to collect this information before reaching the quote form page.

Also even if we want to stay close to the Insurance Api, the `Quote` model still reflects a quote created for a specific lead and does not store necessarily all the attributes needed to consume the Api. For example:
- `coverage_ceiling_formula` and `deductible_formula` are collected on the quote form page, but are not stored in the `Quote` model. Those attributes are used to consume the Api but then only the real `coverage_ceiling` and `deductible` values are stored in the `Quote` model
- Only the `covers` requested by the user are stored in the `Quote` record

All these design decisions lead to some unusual `params` manipulation in the  `QuotesController` in order to call the Insurance Api with the correct body and to create the `Quote` record with the correct attributes:
- We need to get `nacebel_codes` from the `Lead` record
- We need to get `coverage_ceiling_formula` and `deductible_formula` from the form params, but don't store it in the `quote` record
- We need to remove from the `InsuranceApi` payload the `covers` not choosen by the user

### Scalability
Because this is still a simple app with limited information, we decided to store some data directly as constant, enums or attributes. Going further this data could be extracted for better scalability. For example:
- `Lead::MEDICAL_NACEBEL_CODES`, `Lead.activities` enum, and `Lead::PROFESSION_BY_NACEBEL_CODE`: are used to store the `Lead` record `activity` and to display the professions on the lead form. This will be hard to maintain and scall with hundreds of activities and NACE-BEL codes. We could imagine a new `Activity` model with a "many to many" relation with the `Lead` model, each `activity` record having many `nacebel_codes` as an array attributes or even it's own `NacebelCode` model etc...
- `covers` is a `jsonb` attribute in the `Quote` model. It could be extracted in its own `Cover` model, with a one to many relation with `Quote`
- The cover advice logic is also computed thanks to `Quote::COVERS_BY_ACTIVITY`, `Quote::DEDUCTIBLE_FORMULA_BY_ACTIVITY`, `Quote::COVERAGE_CEILING_FORMULA_BY_ACTIVITY`. This is not scalable with hundreds of activities and more complexe advice logic, and could be extracted in it's own service

### Specs
We currently only have model specs (to test `Lead` and `Quote` models), and service spec (to test `InsuranceApi::V1::Client`). Going further we would need to create integration specs to test the user journey into the different pages.

### I18n
The app is not i18n ready, all texts (views, validation errors, forms attributes etc...) being hard coded.

### Error handling
The Api errors and exception handling is basic and would need to be more robust in a real production-ready app. For example:
- If the `InsuranceApi::V1::Client` service raises an error we just advice the user to try again. We should first log this exception somewhere, react to it, maybe having a retry mechanism.
- If the `InsuranceApi::V1::Client` is not successful we don't analyse and react to the error data returned. We just rely on our `Quote` model ActiveRecord validation errors, "hoping" it will reflect the Api errors...

We could also use a tool like [Sentry](https://sentry.io/) for error monitoring.

### Optimization
In the `QuotesController#create` method, we call the `InsuranceApi` service before validating that `quote_params` are correct. We could prevent unecessary Api calls by having a more complexe logic to first validate some params, and then call the Api

### Authorization
There are currently no authorization process in the app. Anyone can access the quote page of any lead, or even the quote form to create a quote for any lead.

### Front end
The front end design of the app is really basic and obviously need to be improved.


