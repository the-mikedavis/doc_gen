# DocGen [![Build Status](https://travis-ci.com/the-mikedavis/doc_gen.svg?branch=master)](https://travis-ci.com/the-mikedavis/doc_gen)

A reduced-bias way to create documentaries.

## What is it

DocGen is a tool for documentary creators to present their interview clips and
present them in a way that doesn't impress their bias on the audience. DocGen
allows the administrator to upload and organize videos. Users then select
topics that interest them. DocGen then randomly selects videos proportional
to the users' interests and generates a documentary.

_This project was funded by the University of Miami School of Communication. It
is a collaboration between Kim Grinfeder and Mike Davis._

## How to Install It

You'll need an Ubuntu-based server with PostgreSQL. The releases are designed
for Ubuntu 16.04 but other versions may work equally well. Go into the releases
tab of this repo on GitHub and download `doc_gen.tag.gz` onto your server.
First, create the database under a name of your choice (you may do so using
`createdb <database-name>` on the command line). Then add these lines into
your `/etc/environment`:

- [ ] `DOC_GEN_PORT` - the port you wish to run on
  - if you want to use SSL, I recommend setting up a reverse proxy through [nginx](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/) or [apache](https://httpd.apache.org/docs/2.4/howto/reverse_proxy.html)
- [ ] `DOC_GEN_HOST` - the hostname of your server
- [ ] `DOC_GEN_SECRET_KEYBASE` - a random secret string of (about 65) characters
  - any sort of password manager should be able to generate a good random string for this
- [ ] `DOC_GEN_DB_DATABASE` - the database you created for the application with `createdb`
- [ ] `DOC_GEN_DB_USERNAME` - the username of the PostgreSQL user who owns that database
- [ ] `DOC_GEN_DB_PASSWORD` - the password of the user who owns that database

#### Example

```
DOC_GEN_PORT=4000
DOC_GEN_HOST=example.org
DOC_GEN_SECRET_KEYBASE=SKtholekarcoekhoe
DOC_GEN_DB_DATABASE=doc_gen_prod
DOC_GEN_DB_USERNAME=postgres
DOC_GEN_DB_PASSWORD=postgres
```

But replace these values as described above.

Now extract the application. Use `tar xzf doc_gen.tar.gz` to extract it. You can
now run the app with `bin/doc_gen start` (use `bin/doc_gen stop` to stop it).
If you have your environment sourced, you should first run `bin/mole seed` to
setup the database. (Running it twice won't do anything bad.)

Once you have these in your `/etc/environment`, you can set up a service to run
the application. If your server's power goes out, you won't have to start up
the app manually. (If you don't want to do this, simply `source
/etc/environment`, `bin/doc_gen seed`, and `bin/doc_gen start`.) Here's a
service definition. Write this as `/etc/systemd/system/doc_gen.service`. Now
you'll be able to run `service doc_gen start` and never worry about it again.

```
[Unit]
Description=doc_gen service

[Service]
WorkingDirectory=/root/bin/
ExecStart=/root/bin/doc_gen start
ExecStop=/root/bin/doc_gen stop
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=doc_gen
User=root
RemainAfterExit=yes

EnvironmentFile=/etc/environment

[Install]
WantedBy=multi-user.target
```

## Technologies

This project uses some cool new tech:

* [Elixir](https://elixir-lang.org/): a dynamically typed functional language with great concurrency support and low latency. I use Elixir for all back-end logic.
* [Phoenix Framework](https://phoenixframework.org/): Rails is to Ruby as Phoenix is to Elixir. Phoenix makes it easy to write a web-app backend in Elixir.
* [PostgreSQL](https://www.postgresql.org/): An open-source and easy to use database. Postgres manages all long-term state like information on videos and accounts.
* [Slime](https://slime-lang.com/): Slim HTML with support for templating in Elixir. All pages are rendered using compiled Slime.
* [Elm](https://elm-lang.org/): a statically typed functional language that transpiles to JavaScript. I use Elm on the front-end the same way you might use React or Angular: for dynamically modifying the DOM and doing socket operations.
* [Sass](http://sass-lang.com/documentation/file.INDENTED_SYNTAX.html) (indented style): a suped-up CSS with minimal syntax. Sass handles all stylization.
* [Webpack](https://webpack.js.org/): A build tool for front-end assets. Webpack automatically organizes and transpiles all front-end assets.
* [Tailwind](https://tailwindcss.com/docs/what-is-tailwind/): A css framework for quickly building common interfaces. Tailwind allows me to very quickly construct an easy to use UI without the hassel of writing all the css myself.

## Credits

Design, production, and ideation by Kim Grinfeder. Implementation by Mike Davis.
