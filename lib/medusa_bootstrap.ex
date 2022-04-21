defmodule AppBootstrap do
  @moduledoc """
  Se puso este codigo para tener una copia(offline) de las variables de entorno de la app
  que se llaman como Application.get_env(:medusa,:twilio) desde el modulo MedusaTwilioadapter
  """

  def initialize_envars do
    env_values = %{
      account_sid: 315,
      account_secret: "kd.4dm1n.2022",
      auth_key: "4av04f36wkdweweu369524ew8v0we30wf",
      url: "https://api.bonsaif.com",
      blacklist_catalog:  "",
      regional_area_codes:  ["552",
			     "554",
			     "998",
			     "999"
                             ],
      sms_response_codes: %{
        "200"	=> "Envio Exitoso",
        "410"	=> "Mensaje excede 160 caracteres",
        "430"	=> "Teléfono invalido vs Plan Nacional de Numeración",
        "440"	=> "El número telefónico no es celular",
        "441"	=> "El número transfer no es celular",
        "450"	=> "No hay módems disponibles",
        "460"	=> "Sin crédito para envío sms",
        "501"	=> "Error de autentificación",
      }
    }

    Enum.map(env_values, fn envar ->
      Application.put_env(:medusa, :bonsaif, %{env_values | elem(envar, 0) => elem(envar, 1)})
    end)
  end
end
