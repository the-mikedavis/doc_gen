defmodule DocGen.Repo.Migrations.AddAboutToSettings do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :about, :text
    end
  end
end
