defmodule DoNothing.Extension do
  defmodule Step do
    @type t :: %__MODULE__{
            id: atom(),
            title: String.t(),
            instructions: String.t(),
            run: [DoNothing.Extension.Run.t()]
          }
    defstruct [:id, :title, :instructions, :run]
  end

  defmodule Run do
    @type t :: %__MODULE__{
            execute: {module(), atom()} | fun(),
            output: atom(),
            inputs: [atom()]
          }
    defstruct [:execute, :output, inputs: []]
  end

  @step_schema [
    id: [
      type: :atom,
      required: true
    ],
    title: [
      type: :string,
      required: true
    ],
    instructions: [
      type: :string,
      required: false
    ]
  ]

  @step %Spark.Dsl.Entity{
    name: :step,
    describe: "Adds a step",
    target: Step,
    entities: [
      run: [
        %Spark.Dsl.Entity{
          name: :run,
          target: Run,
          schema: [
            inputs: [type: {:list, :atom}, required: false],
            output: [type: :atom, required: false],
            execute: [type: {:custom, DoNothing.Extension, :is_function, []}, required: true]
          ]
        }
      ]
    ],
    schema: @step_schema
  }

  def is_function(value) when Kernel.is_function(value) do
    {:ok, value}
  end

  def is_function(_) do
    {:error, "Not a function"}
  end

  @procedure %Spark.Dsl.Section{
    # The DSL constructor will be `procedure`
    name: :procedure,
    describe: """
    Configure the DoNothing procedure.
    """,
    entities: [
      # See `Spark.Dsl.Entity` docs
      @step
    ],
    top_level?: true,
    schema: [
      title: [
        type: :string
      ],
      description: [
        type: :string
      ]
    ]
  }

  use Spark.Dsl.Extension, sections: [@procedure]
end
