defmodule DocGen.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :title, :string
      add :length, :integer
      add :copy, :text

      timestamps()
    end

  end
end
