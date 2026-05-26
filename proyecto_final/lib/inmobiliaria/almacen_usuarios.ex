defmodule Inmobiliaria.AlmacenUsuarios do
  @moduledoc """
  Persistencia de usuarios en users.dat
  Formato: nombre_usuario:contraseña_hash:rol:puntos
  """

  @ruta_archivo "data/users.dat"

  @doc """
  Guarda todos los usuarios en el archivo.
  """
  def guardar_usuarios(usuarios) do
    contenido = Enum.map(usuarios, fn {_, usuario} ->
      "#{usuario.nombre_usuario}:#{usuario.contraseña_hash}:#{usuario.rol}:#{usuario.puntos}\n"
    end)

    File.write!(@ruta_archivo, contenido)
    :ok
  end

  @doc """
  Carga los usuarios desde el archivo.
  Retorna un mapa de nombre_usuario -> %Usuario{}
  """
  def cargar_usuarios do
    case File.read(@ruta_archivo) do
      {:ok, contenido} ->
        contenido
        |> String.split("\n", trim: true)
        |> Enum.map(&procesar_linea/1)
        |> Enum.into(%{}, fn usuario -> {usuario.nombre_usuario, usuario} end)
      {:error, :enoent} ->
        %{}
      {:error, razon} ->
        IO.puts("Error al cargar usuarios: #{razon}")
        %{}
    end
  end

  @doc """
  Guarda un solo usuario (agregar o actualizar).
  """
  def guardar_usuario(usuario) do
    usuarios = cargar_usuarios()
    usuarios_actualizados = Map.put(usuarios, usuario.nombre_usuario, usuario)
    guardar_usuarios(usuarios_actualizados)
  end

  # ─── Funciones Privadas ───
  defp procesar_linea(linea) do
    [nombre, hash, rol, puntos] = String.split(linea, ":")
    %Inmobiliaria.TiposDatos.Usuario{
      nombre_usuario: nombre,
      contraseña_hash: hash,
      rol: String.to_atom(rol),
      puntos: String.to_integer(puntos)
    }
  end
end
