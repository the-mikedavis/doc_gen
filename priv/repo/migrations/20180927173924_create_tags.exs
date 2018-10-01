defmodule DocGen.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:weight, :integer)
      add(:name, :string, null: false)
      add(:video_id, references(:videos))

      timestamps()
    end

    create(unique_index(:tags, [:name]))
  end
end
