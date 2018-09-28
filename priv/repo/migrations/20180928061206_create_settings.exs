defmodule DocGen.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :name, :string
      add :length, :integer

      timestamps()
    end

  end
end
