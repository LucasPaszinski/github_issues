defmodule Issues.GitHub do
  @user_agent [{"User-agent", "Elixir dave@pragprog.com"}]

  require Logger

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  @doc """
  return the issues url for given user and project

    ## Examples

      iex> Issues.GitHub.issues_url("ted","helloworld")
      "https://api.github.com/repos/ted/helloworld/issues"

  """
  def issues_url(user, project) do
    "#{Application.get_env(:issues, :github_url)}/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    {
      status_code |> check_for_error(),
      body |> Poison.Parser.parse!(%{})
    }
  end

  defp check_for_error(200) do
    :ok
  end

  defp check_for_error(_) do
    :error
  end
end
