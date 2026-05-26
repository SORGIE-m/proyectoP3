defmodule Inmobiliaria.Application do
  @moduledoc """
  Punto de entrada OTP. Inicia el supervisor principal
  que maneja todos los procesos del sistema.
  """
  use Application

  @impl true
  def start(_tipo, _args) do
    Inmobiliaria.GestorPersistencia.inicializar_archivos()

    hijos = [
      {DynamicSupervisor, strategy: :one_for_one, name: Inmobiliaria.SupervisorPropiedades},
      {Inmobiliaria.Servidor, []}
    ]

    opciones = [strategy: :one_for_one, name: Inmobiliaria.SupervisorPrincipal]
    {:ok, pid} = Supervisor.start_link(hijos, opciones)

    Inmobiliaria.GestorPersistencia.cargar_usuarios_al_servidor()
    Inmobiliaria.GestorPropiedades.cargar_propiedades_guardadas()

    {:ok, pid}
  end
end
