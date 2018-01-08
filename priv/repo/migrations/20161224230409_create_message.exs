defmodule Vuechat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :username, :string
      add :body, :text
      add :room, :integer

      timestamps()
    end

    create index(:messages, :inserted_at)
  end
end
