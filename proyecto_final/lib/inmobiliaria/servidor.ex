defmodule Inmobiliaria.Servidor do
  @moduledoc """
  Servidor principal que mantiene el estado global del sistema:
  - Usuarios registrados
  - Usuarios conectados
  - Rankings
  """
  use Agent

  alias Inmobiliaria.TiposDatos.Usuario

  # ─── API Pública ───
  def start_link(_opciones) do
    Agent.start_link(fn -> estado_inicial() end, name: __MODULE__)
  end

  @doc """
  Registra un nuevo usuario en el sistema.
  """
  def registrar_usuario(nombre, contraseña, rol) do
    Agent.get_and_update(__MODULE__, fn estado ->
      if Map.has_key?(estado.usuarios, nombre) do
        {{:error, :usuario_existe}, estado}
      else
        usuario = %Usuario{
          nombre_usuario: nombre,
          contraseña_hash: cifrar_contraseña(contraseña),
          rol: rol,
          puntos: 0
        }

        nuevos_usuarios = Map.put(estado.usuarios, nombre, usuario)
        nuevo_estado = %{estado | usuarios: nuevos_usuarios}
        Inmobiliaria.AlmacenUsuarios.guardar_usuario(usuario)
        {{:ok, usuario}, nuevo_estado}
      end
    end)
  end

  @doc """
  Inicia sesión de un usuario existente.
  """
  def iniciar_sesion(nombre, contraseña) do
    Agent.get_and_update(__MODULE__, fn estado ->
      case Map.get(estado.usuarios, nombre) do
        nil ->
          {{:error, :usuario_no_encontrado}, estado}

        usuario ->
          if usuario.contraseña_hash == cifrar_contraseña(contraseña) do
            conectados = Map.put(estado.conectados, nombre, usuario)
            {{:ok, usuario}, %{estado | conectados: conectados}}
          else
            {{:error, :contraseña_invalida}, estado}
          end
      end
    end)
  end

  @doc """
  Cierra la sesión de un usuario.
  """
  def cerrar_sesion(nombre) do
    Agent.update(__MODULE__, fn estado ->
      %{estado | conectados: Map.delete(estado.conectados, nombre)}
    end)
  end

  @doc """
  Obtiene la información de un usuario por su nombre.
  """
  def obtener_usuario(nombre) do
    Agent.get(__MODULE__, fn estado -> Map.get(estado.usuarios, nombre) end)
  end

  @doc """
  Verifica si un usuario está conectado.
  """
  def esta_conectado?(nombre) do
    Agent.get(__MODULE__, fn estado -> Map.has_key?(estado.conectados, nombre) end)
  end

  @doc """
  Agrega puntos a un usuario.
  """
  def agregar_puntos(nombre, puntos) do
    Agent.update(__MODULE__, fn estado ->
      case Map.get(estado.usuarios, nombre) do
        nil ->
          estado

        usuario ->
          usuario_actualizado = %{usuario | puntos: usuario.puntos + puntos}
          usuarios = Map.put(estado.usuarios, nombre, usuario_actualizado)

          conectados =
            if Map.has_key?(estado.conectados, nombre) do
              Map.put(estado.conectados, nombre, usuario_actualizado)
            else
              estado.conectados
            end

          %{estado | usuarios: usuarios, conectados: conectados}
      end
    end)
  end

  @doc """
  Obtiene el ranking global de usuarios ordenado por puntos.
  Retorna una lista de tuplas {nombre_usuario, puntos, rol}
  """
  def obtener_ranking do
    Agent.get(__MODULE__, fn estado ->
      estado.usuarios
      |> Map.values()
      |> Enum.sort_by(& &1.puntos, :desc)
      |> Enum.map(fn u -> {u.nombre_usuario, u.puntos, u.rol} end)
    end)
  end

  @doc """
  Obtiene el ranking filtrado por rol.
  """
  def obtener_ranking_por_rol(rol) do
    Agent.get(__MODULE__, fn estado ->
      estado.usuarios
      |> Map.values()
      |> Enum.filter(fn u -> u.rol == rol end)
      |> Enum.sort_by(& &1.puntos, :desc)
      |> Enum.map(fn u -> {u.nombre_usuario, u.puntos} end)
    end)
  end

  # ─── Funciones Privadas ───
  defp estado_inicial do
    %{
      # nombre_usuario -> %Usuario{}
      usuarios: %{},
      # nombre_usuario -> %Usuario{} (sesiones activas)
      conectados: %{}
    }
  end

  defp cifrar_contraseña(contraseña) do
    :crypto.hash(:sha256, contraseña) |> Base.encode16()
  end

  @doc """
  Registra un usuario cargado desde archivo (sin validar contraseña).
  Solo para uso interno de persistencia.
  """
  def registrar_usuario_cargado(usuario) do
    Agent.update(__MODULE__, fn estado ->
      usuarios = Map.put(estado.usuarios, usuario.nombre_usuario, usuario)
      %{estado | usuarios: usuarios}
    end)
  end
end
