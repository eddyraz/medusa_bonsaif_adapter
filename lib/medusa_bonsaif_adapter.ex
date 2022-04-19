defmodule MedusaBonsaifAdapter do
  require Logger
  use GenServer
  @config Application.get_env(:medusa, :bonsaif)

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def send_sms(phone, message) do
    params = %{
      "key" => @config[:auth_key],
      "phone" => phone,
      "message" => message,
      "tipo_sms" => 1,
      # "account" => "Miio",
      "out" => "json"
    }

    auth = authorization()
    url = url()
    url = url <> "/sms?" <> URI.encode_query(params)
    send_request(url, params["phone"])
  end

  @doc """
  En Este modulo para hacer la llamada a la APi de Twilio
  se puede cambiar la libreria HTTPotion or Tesla
  ya que la primera esa marcada como deprecated al correr mix deps.get
  y aconsejan migrar a Tesla(se creo una rama en el git con este feature)
  """
  defp send_request(url, from_phone) do
    Logger.info("Bonsaif Request: #{url}")

    HTTPotion.get(url,
      headers: [
        "User-Agent": "Elixir",
        "Content-Type": "application/x-www-form-urlencoded",
        Accept: "*/*",
        authorization: "Basic " <> authorization(),
        "cache-control": "no-cache"
      ],
      timeout: 60_000
    )
    |> parse_response(from_phone)
  end

  @doc """
  En este modulo se devuelve el json parseado si los codigos de estado de http son del grupo de:
  100(informativos)
  200(enviado, en cola, etc),
  ó 300(codigos de redireccion)

  Si fueran 400(Errores del cliente Ej (llamada a API mal conformada)) o 500(Errores del Servidor)
  entonces se devuelve el error

  (Hubo que ajustar el codigo pues en la API de BONSAIF usan el 200 siempre en plan("OK recibi el query"),
  y despues dentro del json de respuesta es que ponen el error real Ej(
    13:43:10.692 [error] ["Bonsaif Inner Error": "{\"result\":[{ \"id\": \"315_220416_124310_BFZ2\",  \"code\": \"440\",  \"message\": \"NO ES TELEFONO MOVIL\",  \"total_secciones\": \"1\",  \"uuid\": \"0\" } ]}\n"]
  ))
  """

  def parse_response(res, sending_number) do
    phone_number = sending_number

    #     with {:true,Regex.match?(~r/^(10|20|30[0-9])/, "#{res.status_code}")} <-

    if Regex.match?(~r/^(10|20|30[0-9])/, "#{res.status_code}") do
      Logger.info("Bonsaif Response: #{res.status_code}")
      check_number_requirements(res, phone_number)
      # {:ok, cuerpo_respuesta} = Jason.decode(res.body)

      # if Regex.match?(~r/^(10|20|30[0-9])/,List.first(cuerpo_respuesta["result"])["code"]) do
      #  Logger.info("Bonsai SMS Delivery Response; #{res.body}")
      #  Jason.decode(res.body)
      # else
      #  Logger.error("Bonsaif SMS Delivery Error": "#{res.body}")
      #  Jason.decode(res.body)
      # end
      # else
      # Logger.error("Bonsaif Response: #{res.body}")
      # {:error, res.body}
    end
  end

  defp check_http_status_codes(http_response) do
    Logger.info("Bonsaif Response: #{http_response.status_code}")
    Jason.decode(http_response.body)
  end

  defp check_sms_codes(sms_codes) do
    sms_codes
  end

  defp check_number_requirements(server_response, number) do
    if number |> to_charlist |> length == 10 do
      {:ok, cuerpo_respuesta} = Jason.decode(server_response.body)
    else
      Logger.error("Bonsaif SMS Delivery Error #{server_response.body}")
    end
  end

  defp url do
    @config[:url]
  end

  defp authorization do
    Base.encode64("#{@config[:account_sid]}" <> ":" <> "#{@config[:account_secret]}")
  end
end
