defmodule CmdTest do
  use ExUnit.Case

  doctest Issues.Cmd

  import Issues.Cmd, only: [parse_args: 1, sort_in_descending_order: 1]

  test ":help returned option by parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "three values returned if three given" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "count is defaulted if two given" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end

  test "Sort into descending order" do
    result = sort_in_descending_order(fake_created_at_list(["a", "c", "b"]))
    issues = for issue <- result do
      Map.get(issue,"created_at")
    end
    assert issues == ~w{c b a}
  end

  defp fake_created_at_list(values) do
    for value <- values do
      %{"created_at" => value, "other_data" => "xxx"}
    end
  end

end
