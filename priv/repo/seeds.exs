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

alias DocGen.{Accounts.User, Accounts.Setting, Content.Type, Repo}

# seed the administrator

unless Repo.get_by(User, username: "adminimum") do
  %User{}
  |> User.changeset(%{username: "adminimum", password: "pleasechangethis"})
  |> Repo.insert!()
end

# seed the video types

for t <- ["Interview", "B-roll"] do
  Repo.get_by(Type, name: t) || Repo.insert!(%Type{name: t})
end

# seed the settings

unless Repo.one(Setting) do
  %Setting{name: "My Documentary", length: 360}
  |> Repo.insert!()
end
