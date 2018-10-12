defmodule DocGen.Repo.Migrations.CreateInterviewees do
  use Ecto.Migration

  def change do
    create table(:interviewees) do
      add :name, :string

      timestamps()
    end

  end
end
