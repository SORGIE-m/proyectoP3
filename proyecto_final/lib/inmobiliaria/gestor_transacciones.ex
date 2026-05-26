defmodule Inmobiliaria.GestorTransacciones do
  @moduledoc """
  Gestiona las operaciones de compra y arriendo de propiedades.
  Maneja la concurrencia para evitar que dos clientes
  operen simultáneamente sobre la misma propiedad.
  """

  alias Inmobiliaria.TiposDatos.Transaccion

  @puntos_comprador 10
  @puntos_vendedor 15

  @doc """
  Procesa la compra de una propiedad.
  Retorna {:ok, transaccion} o {:error, razon}
  """
  def comprar(id_propiedad, comprador) do
    case Inmobiliaria.GestorPropiedades.comprar_propiedad(id_propiedad, comprador) do
      {:ok, precio, vendedor} ->
        procesar_operacion(comprador, vendedor, id_propiedad, precio, :compra)
      {:error, razon} ->
        {:error, razon}
    end
  end

  @doc """
  Procesa el arriendo de una propiedad.
  Retorna {:ok, transaccion} o {:error, razon}
  """
  def arrendar(id_propiedad, arrendatario) do
    case Inmobiliaria.GestorPropiedades.arrendar_propiedad(id_propiedad, arrendatario) do
      {:ok, precio, arrendador} ->
        procesar_operacion(arrendatario, arrendador, id_propiedad, precio, :arriendo)
      {:error, razon} ->
        {:error, razon}
    end
  end

  # ─── Funciones Privadas ───
  defp procesar_operacion(cliente, responsable, id_propiedad, precio, tipo) do
    propiedad = Inmobiliaria.GestorPropiedades.obtener_propiedad(id_propiedad)

    if propiedad == nil do
      {:error, :propiedad_no_encontrada}
    else
      # Otorgar puntos
      Inmobiliaria.Servidor.agregar_puntos(cliente, @puntos_comprador)
      Inmobiliaria.Servidor.agregar_puntos(responsable, @puntos_vendedor)

      # Crear registro de transacción
      transaccion = %Transaccion{
        fecha: fecha_actual(),
        cliente: cliente,
        responsable: responsable,
        id_propiedad: id_propiedad,
        tipo: tipo,
        ubicacion: propiedad.ubicacion,
        precio: precio,
        estado: :completada
      }

      # Guardar en archivo de resultados
      Inmobiliaria.GestorPersistencia.guardar_transaccion(transaccion)

      {:ok, transaccion}
    end
  end

  defp fecha_actual do
    hoy = Date.utc_today()
    "#{hoy.year}-#{pad(hoy.month)}-#{pad(hoy.day)}"
  end

  defp pad(numero) when numero < 10, do: "0#{numero}"
  defp pad(numero), do: "#{numero}"
end
