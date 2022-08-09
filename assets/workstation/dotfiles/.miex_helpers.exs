Code.compiler_options(ignore_module_conflict: false)

defmodule M do
  def mx(task) do
    mx(task, [])
  end

  def mx(task, args) do
    Mix.Task.reenable task
    Mix.Task.run task, args
  end

  def mxf() do
    if File.regular?("./formatter.exs") do
      mx("format")
    end
  end

  def r do
    mxf()
    IEx.Helpers.recompile()
  end

  def lookup(call) do
    [Atom, Enum, Map, List, String, Kernel, File, Path]
    |> Enum.group_by(&(&1), &lookup(&1, call))
  end

  def lookup(module, call) do
    module.module_info(:exports)
    |> Enum.filter(&(export_similar?(&1, call)))
  end

  def export_similar?({export, _}, call) do
    String.jaro_distance(Atom.to_string(export), call) > 0.70
  end
end
