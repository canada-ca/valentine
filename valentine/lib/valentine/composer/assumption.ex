defmodule Valentine.Composer.Assumption do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder,
           only: [
             :id,
             :workspace_id,
             :numeric_id,
             :content,
             :comments,
             :tags
           ]}

  schema "assumptions" do
    belongs_to :workspace, Valentine.Composer.Workspace

    field :numeric_id, :integer
    field :comments, :string
    field :content, :string
    field :tags, {:array, :string}, default: []

    many_to_many :threats, Valentine.Composer.Threat, join_through: "assumptions_threats"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(assumption, attrs) do
    assumption
    |> cast(attrs, [:content, :comments, :tags, :workspace_id])
    |> validate_required([:content, :workspace_id])
    |> set_numeric_id()
    |> unique_constraint(:numeric_id, name: :assumptions_workspace_id_numeric_id_index)
    |> unique_constraint(:id)
    |> foreign_key_constraint(:workspace_id)
  end

  defp set_numeric_id(changeset) do
    case get_field(changeset, :numeric_id) do
      nil ->
        case get_field(changeset, :workspace_id) do
          nil ->
            changeset

          workspace_id ->
            last_assumption =
              Valentine.Repo.one(
                from t in __MODULE__,
                  where: t.workspace_id == ^workspace_id,
                  order_by: [desc: t.numeric_id],
                  limit: 1
              )

            put_change(
              changeset,
              :numeric_id,
              (last_assumption && last_assumption.numeric_id + 1) || 1
            )
        end

      _ ->
        changeset
    end
  end
end
