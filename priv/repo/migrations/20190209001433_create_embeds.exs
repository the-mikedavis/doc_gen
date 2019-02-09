defmodule DocGen.Repo.Migrations.CreateEmbeds do
  use Ecto.Migration

  def change do
    create table(:embeds) do
      add(:link, :string)
      add(:name, :string)

      timestamps()
    end
  end
end
