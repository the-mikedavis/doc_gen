# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DocGen.Repo.insert!(%DocGen.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias DocGen.{Accounts.User, Repo}

%User{}
|> User.changeset(%{username: "adminimum", password: "pleasechangethis"})
|> IO.inspect()
|> Repo.insert!()
