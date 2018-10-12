defmodule DocGen.Repo.Migrations.AddIntervieweeToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add(:interviewee_id, references(:interviewees))
    end
  end
end
