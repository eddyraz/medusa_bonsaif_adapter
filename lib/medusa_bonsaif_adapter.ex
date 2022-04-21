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

    IO.inspect(@config[:regional_area_codes])
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

  defp parse_response(res, sending_number) do

    #Testeo de codigo para acceder al SMS code



    if Regex.match?(~r/^(10|20|30[0-9])/, "#{res.status_code}") do
      Logger.info("Bonsaif Response: #{res.status_code}")
      check_number_requirements(res, sending_number)
    end
  end


  defp check_sms_status_code(server_resp) do
     Regex.match?(~r/^(4[1|3-6][0-1])/,String.slice(server_resp.body,55..57))
  end



  defp check_number_requirements(server_response, number) do
    check_sms_status_code(server_response)
    if number |> to_charlist |> length != 10 or  check_sms_status_code(server_response) do
      Logger.error("Bonsaif SMS Delivery Error #{server_response.body}")
    else
      {:ok, cuerpo_respuesta} = Jason.decode(server_response.body)
    end
  end

  defp url do
    @config[:url]
  end

  defp authorization do
    Base.encode64("#{@config[:account_sid]}" <> ":" <> "#{@config[:account_secret]}")
  end
end
