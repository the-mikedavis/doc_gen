defmodule DocGen.Repo.Migrations.AddSegmentToVideosRemoveWeight do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add(:segment_id, references(:segments))
      remove(:weight)
    end
  end
end
