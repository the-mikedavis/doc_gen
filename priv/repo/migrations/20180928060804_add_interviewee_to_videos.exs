defmodule DocGen.Repo.Migrations.AddIntervieweeToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add(:interviewee, :string)
    end
  end
end
