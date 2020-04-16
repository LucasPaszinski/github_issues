defmodule Issues.Cmd do
  @default_count 4

  @moduledoc """
  Handle the command line and the dispatch
  to various functions that end up
  genrating the table of the last nº of
  issues in a given github project
  """

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help which return :help.

  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.

  Return a tuple of `{ user, project, count}`, or `:help` if help was given.
  """
  def parse_args(argv) do
    argv
    |> OptionParser.parse(
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    # only the second elemente of the tuple metters
    |> elem(1)
    |> args_to_value
  end

  defp args_to_value([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  defp args_to_value([user, project]) do
    {user, project, @default_count}
  end

  defp args_to_value(_) do
    :help
  end

  def process(:help) do
    IO.puts("usage: ./issues <user> <project> [count | #{@default_count}]")
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GitHub.fetch(user, project)
    |> decode_response()
    |> sort_in_descending_order()
    |> last(count)
    |> Issues.TableFormater.print_table_for_columns(["number","created_at","title"])
  end

  def decode_response({:ok, body}) do
    body
  end

  def decode_response({:erro, error}) do
    IO.puts "Error fetching from Github: #{error}"
    System.halt(2)
  end

  def sort_in_descending_order(list) do
    list
    |> Enum.sort(&(&1["created_at"]>= &2["created_at"]))
  end

  def last(list,count) do
    list
    |> Enum.take(count)
    |> Enum.reverse
  end
end
