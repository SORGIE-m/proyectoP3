defmodule Inmobiliaria.Puente do
  def iniciar do
    IO.puts("PUENTE INICIADO - Esperando comandos...")
    bucle()
  end

  defp bucle do
    case File.read("data/comando.txt") do
      {:ok, c} ->
        File.rm!("data/comando.txt")
        partes = c |> String.trim() |> String.split("|")
        cmd = List.first(partes)
        args = partes |> tl() |> Enum.filter(&(&1 != ""))

        try do
          case Inmobiliaria.API.ejecutar(cmd, args) do
            {:ok, r} -> File.write!("data/respuesta.txt", "OK:" <> inspect(r))
            {:error, e} -> File.write!("data/respuesta.txt", "ERROR:" <> inspect(e))
            r -> File.write!("data/respuesta.txt", "OK:" <> inspect(r))
          end
        rescue
          e -> File.write!("data/respuesta.txt", "ERROR:" <> inspect(e))
        end

      {:error, _} ->
        Process.sleep(200)
    end

    bucle()
  end
end

defmodule Inmobiliaria.API do
  def ejecutar("registrar", [user, pass, rol]) do
    case Inmobiliaria.Servidor.registrar_usuario(user, pass, String.to_atom(rol)) do
      {:ok, _} -> {:ok, "registrado"}
      {:error, razon} -> {:error, razon}
    end
  end

  def ejecutar("login", [user, pass]) do
    case Inmobiliaria.Servidor.iniciar_sesion(user, pass) do
      {:ok, u} -> {:ok, u}
      {:error, razon} -> {:error, razon}
    end
  end

  def ejecutar("listar", []) do
    {:ok, Inmobiliaria.GestorPropiedades.listar_propiedades()}
  end

  def ejecutar("ranking_compradores", []) do
    {:ok, Inmobiliaria.Servidor.obtener_ranking_por_rol(:cliente)}
  end

  def ejecutar("ranking_vendedores", []) do
    {:ok, Inmobiliaria.Servidor.obtener_ranking_por_rol(:vendedor)}
  end

  def ejecutar("ranking_arrendadores", []) do
    {:ok, Inmobiliaria.Servidor.obtener_ranking_por_rol(:arrendador)}
  end

  def ejecutar("publicar", [t, m, u, p, a, h, b, d, prop]) do
    Inmobiliaria.GestorPropiedades.publicar_propiedad(%{
      tipo: String.to_atom(t),
      modalidad: String.to_atom(m),
      ubicacion: u,
      precio: String.to_integer(p),
      area: String.to_integer(a),
      habitaciones: String.to_integer(h),
      baños: String.to_integer(b),
      descripcion: d,
      propietario: prop
    })
  end

  def ejecutar("comprar", [id, user]) do
    Inmobiliaria.GestorTransacciones.comprar(id, user)
  end

  def ejecutar("arrendar", [id, user]) do
    Inmobiliaria.GestorTransacciones.arrendar(id, user)
  end

  def ejecutar("ranking", []) do
    {:ok, Inmobiliaria.Servidor.obtener_ranking()}
  end

  def ejecutar(_, _), do: {:error, "comando desconocido"}
end

# ─── Inicialización del sistema ───
Inmobiliaria.GestorPersistencia.inicializar_archivos()
Inmobiliaria.GestorPersistencia.cargar_usuarios_al_servidor()
Inmobiliaria.GestorPropiedades.cargar_propiedades_guardadas()
IO.puts("✅ SERVIDOR LISTO")

Inmobiliaria.Puente.iniciar()
