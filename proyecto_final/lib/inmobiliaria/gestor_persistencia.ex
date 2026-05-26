defmodule Inmobiliaria.GestorPersistencia do
  @moduledoc """
  Módulo central de persistencia que coordina
  la carga y guardado de todos los datos del sistema.
  """

  alias Inmobiliaria.AlmacenUsuarios

  @doc """
  Carga los usuarios desde el archivo al servidor en memoria.
  """
  def cargar_usuarios_al_servidor do
    usuarios = AlmacenUsuarios.cargar_usuarios()
    # Los carga en el Agent del Servidor
    Enum.each(usuarios, fn {_, usuario} ->
      Inmobiliaria.Servidor.registrar_usuario_cargado(usuario)
    end)

    {:ok, map_size(usuarios)}
  end

  @doc """
  Guarda todos los usuarios desde el servidor al archivo.
  """
  def guardar_usuarios_desde_servidor do
    usuarios = Agent.get(Inmobiliaria.Servidor, fn estado -> estado.usuarios end)
    AlmacenUsuarios.guardar_usuarios(usuarios)
  end

  @doc """
  Guarda una transacción en results.log
  Formato: fecha; cliente=xxx; responsable=xxx; propiedad=xxx; operacion=xxx; ubicacion=xxx; precio=xxx; estado=xxx
  """
  def guardar_transaccion(transaccion) do
    linea = formatear_transaccion(transaccion)
    File.write!("data/results.log", linea <> "\n", [:append])
    :ok
  end

  @doc """
  Guarda un mensaje en messages.log
  Formato: [fecha_hora] de=xxx -> para=xxx (propiedad=xxx): contenido
  """
  def guardar_mensaje(mensaje) do
    linea = formatear_mensaje(mensaje)
    File.write!("data/messages.log", linea <> "\n", [:append])
    :ok
  end

  @doc """
  Inicializa los archivos de datos si no existen.
  """
  def inicializar_archivos do
    archivos = [
      {"data/users.dat", ""},
      {"data/properties.dat", ""},
      {"data/results.log", ""},
      {"data/messages.log", ""},
      {"data/locations.dat",
       "Armenia\nCalarcá\nQuimbaya\nMontenegro\nLa Tebaida\nCircasia\nFilandia\nSalento\n"}
    ]

    Enum.each(archivos, fn {ruta, contenido_predeterminado} ->
      unless File.exists?(ruta) do
        File.write!(ruta, contenido_predeterminado)
      end
    end)

    :ok
  end

  # ─── Funciones Privadas ───
  defp formatear_transaccion(t) do
    "#{t.fecha}; cliente=#{t.cliente}; responsable=#{t.responsable}; propiedad=#{t.id_propiedad}; operacion=#{t.tipo}; ubicacion=#{t.ubicacion}; precio=#{t.precio}; estado=#{t.estado}"
  end

  defp formatear_mensaje(m) do
    "[#{m.fecha_hora}] de=#{m.de} -> para=#{m.para} (propiedad=#{m.id_propiedad}): #{m.contenido}"
  end

  @doc """
  Guarda una propiedad en properties.dat
  """
  def guardar_propiedad(propiedad) do
    linea = formatear_propiedad(propiedad)
    File.write!("data/properties.dat", linea <> "\n", [:append])
    :ok
  end

  @doc """
  Carga todas las propiedades desde properties.dat
  """
  def cargar_propiedades do
    case File.read("data/properties.dat") do
      {:ok, contenido} ->
        contenido
        |> String.split("\n", trim: true)
        |> Enum.map(&parsear_propiedad/1)

      {:error, _} ->
        []
    end
  end

  defp formatear_propiedad(p) do
    "#{p.id}|#{p.tipo}|#{p.modalidad}|#{p.ubicacion}|#{p.precio}|#{p.area}|#{p.habitaciones}|#{p.baños}|#{p.descripcion}|#{p.propietario}|#{p.estado}"
  end

  defp parsear_propiedad(linea) do
    [
      id,
      tipo,
      modalidad,
      ubicacion,
      precio,
      area,
      habitaciones,
      baños,
      descripcion,
      propietario,
      estado
    ] = String.split(linea, "|")

    %Inmobiliaria.TiposDatos.Propiedad{
      id: id,
      tipo: String.to_atom(tipo),
      modalidad: String.to_atom(modalidad),
      ubicacion: ubicacion,
      precio: String.to_integer(precio),
      area: String.to_integer(area),
      habitaciones: String.to_integer(habitaciones),
      baños: String.to_integer(baños),
      descripcion: descripcion,
      propietario: propietario,
      estado: String.to_atom(estado)
    }
  end
end
