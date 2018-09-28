defmodule DocGen.Repo.Migrations.RemoveTitleFromVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      remove :title
    end
  end
end
