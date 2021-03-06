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

alias DocGen.{
  Accounts.User,
  Accounts.Setting,
  Content.Type,
  Content.Segment,
  Repo
}

# seed the administrator

case Repo.all(User) do
  [] ->
    %User{}
    |> User.changeset(%{username: "adminimum", password: "pleasechangethis"})
    |> Repo.insert!()

  [%User{} | _] ->
    :ok
end

# seed the video types

for t <- ["Interview", "B-roll"] do
  Repo.get_by(Type, name: t) || Repo.insert!(%Type{name: t})
end

# seed the segments
for t <- ["beginning", "middle", "end"] do
  Repo.get_by(Segment, name: t) || Repo.insert!(%Segment{name: t})
end

# seed the settings

starting_copy =
  "Welcome to Doc-Gen. Please edit your copy and other settings by logging in."

starting_about =
  "This instance of Doc-Gen is about ... (please edit this text in Settings)."

unless Repo.one(Setting) do
  %Setting{
    title: "My Documentary",
    beginning_clips: 1,
    middle_clips: 3,
    end_clips: 1,
    copy: starting_copy,
    about: starting_about
  }
  |> Repo.insert!()
end
