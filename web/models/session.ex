defmodule Requestbox.Session do
  use Requestbox.Web, :model
  use Timex.Ecto.Timestamps
  alias Requestbox.Session

  schema "sessions" do

    field :token, :string
    has_many :requests, Requestbox.Request, on_delete: :delete_all
    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(requests token)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:token, min: 4)
  end

  def cleanup() do
    use Timex
    alias Requestbox.Repo

    cutoff = Date.now |> Date.shift(hours: -1)
    # Hack for Ecto + Timex: https://github.com/bitwalker/timex_ecto/issues/8
    |> DateFormat.format!("{ISO}")
    Repo.delete_all from(s in Session, where: s.inserted_at < ^cutoff)
  end
end
