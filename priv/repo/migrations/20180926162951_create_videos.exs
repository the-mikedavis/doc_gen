defmodule DocGen.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :title, :string
      add :slug, :string

      timestamps()
    end

    create unique_index(:videos, [:slug])
  end
end
