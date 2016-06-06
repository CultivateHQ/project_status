defmodule Burnup.ProjectBurnup do
  use GenServer

  alias Burnup.Queries

  defstruct project_id: nil

  def start_link(project_id) do
    GenServer.start_link(__MODULE__, project_id, name: __MODULE__)
  end

  def raw_totals(pid) do
    pid |> GenServer.call(:raw_totals)
  end

  def totals(pid) do
    pid |> GenServer.call(:totals)
  end

  ## Callbacks
  def init(project_id) do
    {:ok, %__MODULE__{project_id: project_id}}
  end

  def handle_call(:raw_totals, _from, state = %{project_id: project_id}) do
    result = Queries.raw_totals(project_id)
    {:reply, result, state}
  end

  def handle_call(:totals, _from, state = %{project_id: project_id}) do
    result = Queries.raw_totals(project_id)
    |> Queries.categorise_totals(Queries.story_status_categories(project_id))
    {:reply, result, state}
  end
end
