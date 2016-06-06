defmodule TodoApp.TodoEntry do
  defstruct id: nil, date: nil, title: ""

  @type t :: %__MODULE__{
    id: integer,
    date: {integer, integer, integer},
    title: String.t
  }

  def new(args \\ []) do
    args = Map.new(args)
    %__MODULE__{} |> Map.merge(args)
  end
end
