defmodule Inmobiliaria.GestorMensajes do
  @moduledoc """
  Gestiona el envío de mensajes entre clientes y
  responsables de propiedades.
  """

  alias Inmobiliaria.TiposDatos.Mensaje

  @doc """
  Envía un mensaje de un cliente al propietario de una propiedad.
  """
  def enviar_mensaje(de, id_propiedad, contenido) do
    propiedad = Inmobiliaria.GestorPropiedades.obtener_propiedad(id_propiedad)

    if propiedad == nil do
      {:error, :propiedad_no_encontrada}
    else
      mensaje = %Mensaje{
        id: generar_id_mensaje(),
        de: de,
        para: propiedad.propietario,
        id_propiedad: id_propiedad,
        contenido: contenido,
        fecha_hora: fecha_hora_actual()
      }

      # Guardar en archivo de mensajes
      Inmobiliaria.GestorPersistencia.guardar_mensaje(mensaje)

      {:ok, mensaje}
    end
  end

  @doc """
  Obtiene todos los mensajes del archivo.
  """
  def obtener_mensajes do
    case File.read("data/messages.log") do
      {:ok, contenido} ->
        contenido
        |> String.split("\n", trim: true)
      {:error, _} -> []
    end
  end

  @doc """
  Obtiene los mensajes dirigidos a un usuario específico.
  """
  def mensajes_para(nombre_usuario) do
    obtener_mensajes()
    |> Enum.filter(fn linea -> String.contains?(linea, "para=#{nombre_usuario}") end)
  end

  @doc """
  Obtiene los mensajes relacionados con una propiedad.
  """
  def mensajes_de_propiedad(id_propiedad) do
    obtener_mensajes()
    |> Enum.filter(fn linea -> String.contains?(linea, "propiedad=#{id_propiedad}") end)
  end

  # ─── Funciones Privadas ───
  defp generar_id_mensaje do
    "msg_" <> (:crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower))
  end

  defp fecha_hora_actual do
    ahora = DateTime.utc_now()
    "#{ahora.year}-#{pad(ahora.month)}-#{pad(ahora.day)} #{pad(ahora.hour)}:#{pad(ahora.minute)}:#{pad(ahora.second)}"
  end

  defp pad(numero) when numero < 10, do: "0#{numero}"
  defp pad(numero), do: "#{numero}"
end
