defmodule FlywithfilmWeb.PageController do
  use FlywithfilmWeb, :controller

  import Ecto.Query
  alias Flywithfilm.Repo
  alias Flywithfilm.Airport

  def home(conn, _params) do
    airports =
      Repo.all(
        from Airport,
          order_by: fragment("RANDOM()"),
          limit: 4
      )
      |> Enum.map(fn airport ->
        %{
          code: airport.iata_code,
          pos: airport.positive_votes,
          neg: airport.negative_votes,
          policies_verified: airport.policies_verified,
          # either :good, :bad, or :pending
          grading:
            if airport.policies_verified do
              if airport.positive_votes > airport.negative_votes do
                :good
              else
                :bad
              end
            else
              :pending
            end
        }
      end)

    conn
    |> assign(:airports, airports)
    |> assign(:search_form, %{})
    |> render(:home)
  end

  def search(conn, %{"airport-code" => iata_code}) do
    conn
    |> redirect(to: "/airports/#{iata_code}")
  end

  def search(conn, _params) do
    conn
    |> redirect(to: "/")
  end

  def list(conn, %{"page" => page_str}) do
    case Integer.parse(page_str) do
      :error ->
        conn |> put_status(:bad_request) |> halt()

      {page, _} when page < 1 ->
        conn |> put_status(:bad_request) |> halt()

      {page, _} ->
        airports =
          Repo.all(
            from Airport,
              order_by: :iata_code,
              limit: 42,
              offset: (^page - 1) * 42
          )
          |> Enum.map(fn airport ->
            %{
              code: airport.iata_code,
              name: airport.name,
              pos: airport.positive_votes,
              neg: airport.negative_votes,
              policies_verified: airport.policies_verified,
              grading:
                if airport.policies_verified do
                  if airport.positive_votes > airport.negative_votes do
                    :good
                  else
                    :bad
                  end
                else
                  :pending
                end
            }
          end)

        conn
        |> assign(:airports, airports)
        |> assign(:page, page)
        |> render(:airport_list)
    end
  end

  def list(conn, _params) do
    list(conn, %{"page" => "1"})
  end

  def airport(conn, %{"airport" => iata_code}) do
    Repo.get_by(Airport, iata_code: String.upcase(iata_code))
    |> Repo.preload([:terminals])
    |> case do
      nil ->
        conn |> render(:no_airport) |> halt()

      airport ->
        conn
        |> assign(:airport, airport)
        |> render(:airport)
    end
  end

  def update(conn, %{"airport" => iata_code}) do
    Repo.get_by(Airport, iata_code: String.upcase(iata_code))
    |> case do
      nil ->
        conn |> render(:no_airport) |> halt()

      airport ->
        conn
        |> assign(:airport, airport)
        |> assign(:form, %{})
        |> render(:airport_suggestion)
    end
  end

  def send_update(conn, %{"airport" => iata_code} = params) do
    if function_exported?(Mix, :env, 0) == false do
      case Hcaptcha.verify(params["h-captcha-response"]) do
        {:error, _errors} ->
          conn
          |> put_flash(:error, "reCAPTCHA error")
          |> redirect(to: "/")
          |> halt()

        _ ->
          post_update_webhook(iata_code, params["feedback"])

          conn |> put_flash(:info, "Thank you for your feedback!") |> redirect(to: "/")
      end
    else
      conn |> redirect(to: "/") |> halt()
    end
  end

  def post_update_webhook(iata_code, feedback) do
    url = Application.get_env(:flywithfilm, :discord_webhook_url)
    headers = [{"Content-type", "application/json"}]
    body = Jason.encode!(%{content: "**Airport:** #{iata_code}\n**Feedback:** #{feedback}"})
    HTTPoison.post(url, body, headers)
  end

  def airport_pos(conn, %{"airport" => iata_code}) do
    Repo.get_by(Airport, iata_code: String.upcase(iata_code))
    |> case do
      nil ->
        conn |> render(:no_airport) |> halt()

      airport ->
        case from(a in Airport,
               update: [inc: [positive_votes: 1]],
               where: a.iata_code == ^airport.iata_code
             )
             |> Repo.one() do
          {:ok, _} ->
            conn |> put_flash(:info, "Thank you for your feedback!") |> redirect(to: "/")

          {:error, _} ->
            conn |> put_flash(:error, "An error occurred") |> redirect(to: "/")
        end
    end
  end

  def airport_neg(conn, %{"airport" => iata_code}) do
    Repo.get_by(Airport, iata_code: String.upcase(iata_code))
    |> case do
      nil ->
        conn |> render(:no_airport) |> halt()

      airport ->
        case from(a in Airport,
               update: [inc: [negative_votes: 1]],
               where: a.iata_code == ^airport.iata_code
             )
             |> Repo.one() do
          {:ok, _} ->
            conn |> put_flash(:info, "Thank you for your feedback!") |> redirect(to: "/")

          {:error, _} ->
            conn |> put_flash(:error, "An error occurred") |> redirect(to: "/")
        end
    end
  end
end
