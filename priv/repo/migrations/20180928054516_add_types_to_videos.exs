defmodule DocGen.Repo.Migrations.AddTypesToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add(:type_id, references(:videos))
    end
  end
end
