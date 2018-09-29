defmodule DocGen.Repo.Migrations.AddWeightToTag do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add(:weight, :integer)
    end
  end
end
