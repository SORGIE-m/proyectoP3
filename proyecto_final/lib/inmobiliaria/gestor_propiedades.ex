defmodule Inmobiliaria.GestorPropiedades do
  @moduledoc """
  Gestiona el catálogo de propiedades y la creación de procesos
  GenServer por cada propiedad publicada.
  """

  alias Inmobiliaria.TiposDatos.Propiedad

  @doc """
  Publica una nueva propiedad y crea su proceso GenServer.
  """
  def publicar_propiedad(atributos) do
    propiedad =
      struct!(
        Propiedad,
        Map.merge(atributos_predeterminados(), atributos)
      )

    # Iniciar un GenServer para esta propiedad
    case DynamicSupervisor.start_child(
           Inmobiliaria.SupervisorPropiedades,
           {Inmobiliaria.Propiedad, propiedad}
         ) do
      {:ok, _pid} ->
        Inmobiliaria.GestorPersistencia.guardar_propiedad(propiedad)
        {:ok, propiedad.id}

      {:error, razon} ->
        {:error, razon}
    end
  end

  @doc """
  Lista todas las propiedades activas, con posibilidad de filtros.
  """
  def listar_propiedades(filtros \\ %{}) do
    catalogo()
    |> aplicar_filtros(filtros)
  end

  @doc """
  Obtiene una propiedad específica por su ID.
  """
  def obtener_propiedad(id) do
    catalogo()
    |> Enum.find(fn p -> p.id == id end)
  end

  @doc """
  Actualiza el estado de una propiedad.
  """
  def actualizar_estado(id, nuevo_estado) do
    pid = obtener_pid_propiedad(id)

    if pid do
      Inmobiliaria.Propiedad.actualizar_estado(pid, nuevo_estado)
    else
      {:error, :propiedad_no_encontrada}
    end
  end

  @doc """
  Intenta comprar una propiedad.
  """
  def comprar_propiedad(id, comprador) do
    pid = obtener_pid_propiedad(id)

    if pid do
      Inmobiliaria.Propiedad.comprar(pid, comprador)
    else
      {:error, :propiedad_no_encontrada}
    end
  end

  @doc """
  Intenta arrendar una propiedad.
  """
  def arrendar_propiedad(id, arrendatario) do
    pid = obtener_pid_propiedad(id)

    if pid do
      Inmobiliaria.Propiedad.arrendar(pid, arrendatario)
    else
      {:error, :propiedad_no_encontrada}
    end
  end

  # ─── Funciones Privadas ───
  defp catalogo do
    DynamicSupervisor.which_children(Inmobiliaria.SupervisorPropiedades)
    |> Enum.map(fn {_, pid, _, _} ->
      Inmobiliaria.Propiedad.obtener_info(pid)
    end)
    # Eliminar nils
    |> Enum.filter(& &1)
  end

  defp obtener_pid_propiedad(id) do
    DynamicSupervisor.which_children(Inmobiliaria.SupervisorPropiedades)
    |> Enum.find(fn {_, pid, _, _} ->
      prop = Inmobiliaria.Propiedad.obtener_info(pid)
      prop && prop.id == id
    end)
    |> case do
      nil -> nil
      {_, pid, _, _} -> pid
    end
  end

  defp aplicar_filtros(propiedades, filtros) do
    propiedades
    |> filtrar_por(:tipo, filtros)
    |> filtrar_por(:modalidad, filtros)
    |> filtrar_por(:ubicacion, filtros)
    |> filtrar_por_rango_precio(filtros)
  end

  defp filtrar_por(lista, _clave, filtros) when map_size(filtros) == 0, do: lista

  defp filtrar_por(lista, clave, filtros) do
    case Map.get(filtros, clave) do
      nil -> lista
      valor -> Enum.filter(lista, fn p -> Map.get(p, clave) == valor end)
    end
  end

  defp filtrar_por_rango_precio(lista, filtros) do
    cond do
      filtros[:precio_min] && filtros[:precio_max] ->
        Enum.filter(lista, fn p ->
          p.precio >= filtros.precio_min && p.precio <= filtros.precio_max
        end)

      filtros[:precio_min] ->
        Enum.filter(lista, fn p -> p.precio >= filtros.precio_min end)

      filtros[:precio_max] ->
        Enum.filter(lista, fn p -> p.precio <= filtros.precio_max end)

      true ->
        lista
    end
  end

  defp atributos_predeterminados do
    %{
      id: generar_id(),
      tipo: :casa,
      modalidad: :venta,
      ubicacion: "",
      precio: 0,
      area: 0,
      habitaciones: 0,
      baños: 0,
      descripcion: "",
      propietario: "",
      estado: :disponible
    }
  end

  defp generar_id do
    "prop_" <> (:crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower))
  end

  @doc """
  Carga propiedades desde el archivo y crea sus procesos GenServer.
  """
  def cargar_propiedades_guardadas do
    Inmobiliaria.GestorPersistencia.cargar_propiedades()
    |> Enum.each(fn propiedad ->
      DynamicSupervisor.start_child(
        Inmobiliaria.SupervisorPropiedades,
        {Inmobiliaria.Propiedad, propiedad}
      )
    end)
  end
end
