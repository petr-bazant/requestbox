defmodule Requestbox.SessionTest.Changeset do
  alias Requestbox.Session
  alias Requestbox.Repo

  defmodule Changeset do

    use Requestbox.ModelCase

    @valid_attrs %{token: "abcd"}
    @invalid_attrs %{token: "ab"}

    test "changeset without token" do
      changeset = Session.changeset(%Session{}, %{})
      assert(changeset.valid?, inspect(changeset.errors))
    end

    test "changeset with valid token" do
      changeset = Session.changeset(%Session{}, %{token: "abcd"})
      assert(changeset.valid?, inspect(changeset.errors))
    end

    test "changeset with invalid token" do
      changeset = Session.changeset(%Session{}, %{token: "ab"})
      refute changeset.valid?
    end
  end

  defmodule Cleanup do

    use Requestbox.ModelCase
    use Timex

    @expired_timestamp Date.now |> Date.shift(days: -1)
    @current_timestamp Date.now |> Date.shift(mins: -1)

    test "cleaneup removes old sessions" do

      now = Date.now
      session = Repo.insert!(%Session{inserted_at: @expired_timestamp})
      Session.cleanup
      refute Repo.get_by(Session, id: session.id)
    end

    test "cleaneup doesn't removes current sessions" do

      now = Date.now
      session = Repo.insert!(%Session{inserted_at: @current_timestamp})
      Session.cleanup
      assert Repo.get_by(Session, id: session.id)
    end
  end
end
