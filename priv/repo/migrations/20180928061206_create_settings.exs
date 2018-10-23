defmodule DocGen.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :title, :string
      add :beginning_clips, :integer
      add :middle_clips, :integer
      add :end_clips, :integer
      add :copy, :text

      timestamps()
    end

  end
end
