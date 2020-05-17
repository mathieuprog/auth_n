defmodule AuthN.Ecto.Migration do
  use Ecto.Migration

  def up(opts \\ []) do
    name = Keyword.get(opts, :name, :users_tokens)
    references = Keyword.get(opts, :references, :users)

    create table(name) do
      add :user_id, references(references, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create unique_index(name, [:context, :token])
  end

  def down(opts \\ []) do
    name = Keyword.get(opts, :name, :users_tokens)

    drop_if_exists index(name, [:context, :token])
    drop_if_exists table(name)
  end
end
