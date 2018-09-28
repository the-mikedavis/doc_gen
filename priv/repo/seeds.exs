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

alias DocGen.{Accounts.User, Content.Type, Repo}

unless Repo.get_by(User, username: "adminimum") do
  %User{}
  |> User.changeset(%{username: "adminimum", password: "pleasechangethis"})
  |> Repo.insert!()
end

for t <- ["Interview", "B-roll"] do
  Repo.get_by(Type, name: t) || Repo.insert!(%Type{name: t})
end
