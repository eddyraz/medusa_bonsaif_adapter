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
      area_codes: %{
        ciudad_mx:"55",
        acapulco:"744",
        apodaca:"81",
        cancun:"998",
        chihuahua:"614",
        ciudad_de_carmen:"938",
        ciudad_madero:"833",
        coatzacoalcos:"921",
        cordoba:"271",
        ensenada:"646",
        guanajuato:"473",
        jiutepec:"777",
        manzanillo:"314",
        mexicali:"686",
        morelia:"443",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",
        :"",

      }
    }

    Enum.map(env_values, fn envar ->
      Application.put_env(:medusa, :bonsaif, %{env_values | elem(envar, 0) => elem(envar, 1)})
    end)
  end
end
