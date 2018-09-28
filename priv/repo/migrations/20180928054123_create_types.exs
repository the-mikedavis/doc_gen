defmodule DocGen.Repo.Migrations.CreateTypes do
  use Ecto.Migration

  def change do
    create table(:types) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
