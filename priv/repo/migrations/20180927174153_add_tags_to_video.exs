defmodule DocGen.Repo.Migrations.AddTagsToVideo do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add(:tag_id, references(:videos))
    end
  end
end
