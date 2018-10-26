# DocGen [![Build Status](https://travis-ci.com/the-mikedavis/doc_gen.svg?branch=master)](https://travis-ci.com/the-mikedavis/doc_gen)

A reduced-bias way to create documentaries.

## Technologies

This project uses some cool new tech:

* [Elixir](https://elixir-lang.org/): a dynamically typed functional language with great concurrency support and low latency. I use Elixir for all back-end logic.
* [Phoenix Framework](https://phoenixframework.org/): Rails is to Ruby as Phoenix is to Elixir. Phoenix makes it easy to write a web-app backend in Elixir.
* [PostgreSQL](https://www.postgresql.org/): An open-source and easy to use database. Postgres manages all long-term state like information on videos and accounts.
* [Slime](https://slime-lang.com/): Slim HTML with support for templating in Elixir. All pages are rendered using compiled Slime.
* [Elm](https://elm-lang.org/): a statically typed functional language that transpiles to JavaScript. I use Elm on the front-end the same way you might use React or Angular: for dynamically modifying the DOM and doing socket operations.
* [Sass](http://sass-lang.com/documentation/file.INDENTED_SYNTAX.html) (indented style): a suped-up CSS with minimal syntax. Sass handles all stylization.
* [Webpack](https://webpack.js.org/): A build tool for front-end assets. Webpack automatically organizes and transpiles all front-end assets.
* [Tailwind](https://tailwindcss.com/docs/what-is-tailwind/): A css framework for quickly building common interfaces.

## Installation for the dev environment

To get this up and running for development on your computer, you'll need

- [ ] Install postgresql
    - `brew install postgresql`
    - If you have custom passwords and rules, you'll have to change the password in `config/dev.exs`.
- [ ] Install Elixir
    - `brew install elixir`
- [ ] Clone this repo
    - `git clone https://github.com/the-mikedavis/doc_gen.git && cd doc_gen/`
- [ ] Install dependencies and compile
    - `mix deps.get`
    - `mix compile`
- [ ] Create the database and do migrations
    - `mix ecto.setup`
- [ ] Setup front-end assets
    - `npm install --global yarn`
    - `npm install --global elm@0.18.0` or `yarn global add elm@0.18.0`
    - `cd assets`
    - `yarn install`
    - `cd ..`
- [ ] Run the dev server
    - `mix phx.server`
    - If you change any files, you won't have to restart the server or refresh your page. This will be done automatically for you.
