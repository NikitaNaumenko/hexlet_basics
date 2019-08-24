defmodule HexletBasicsWeb.Plugs.AssignGlobals do
  @moduledoc false
  import PhoenixGon.Controller
  import Plug.Conn
  require Logger

  @spec init(Keyword.t) :: Keyword.t
  def init(opts), do: opts

  @spec call(Plug.Conn.t, Keyword.t) :: Plug.Conn.t
  def call(conn, _opts) do
    locale = conn.assigns[:locale]
    current_user = conn.assigns[:current_user]

    configuration1 = [:ga, :disqus, :gtm]
                     |> Enum.map(&({&1, "#{&1}_#{locale}"}))
                     |> Enum.reduce(%{}, fn {key, local_key}, acc ->
                       value = Application.fetch_env!(:hexlet_basics, String.to_atom(local_key))
                       Map.put(acc, key, value)
                     end)
    configuration2 = %{locale: locale, current_user: current_user}
    configuration = Map.merge(configuration1, configuration2)
    Logger.info inspect ["Params For Gon", configuration]

    conn
    |> put_gon(configuration)
    |> assign(:ga, configuration1.ga)
    |> assign(:gtm, configuration1.gtm)
    |> assign(:meta_attrs, [])
    |> assign(:link_attrs, [])
    |> assign(:title, Gettext.gettext(HexletBasicsWeb.Gettext, "Code Basics Title"))
  end
end

