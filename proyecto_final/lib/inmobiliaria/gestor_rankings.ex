defmodule Inmobiliaria.GestorRankings do
  @moduledoc """
  Gestiona los rankings de usuarios del sistema.
  Permite consultar ranking global y por rol.
  """

  @doc """
  Obtiene el ranking global de todos los usuarios.
  Retorna lista de mapas ordenados por puntos.
  """
  def ranking_global do
    Inmobiliaria.Servidor.obtener_ranking()
    |> Enum.map(fn {nombre, puntos, rol} ->
      %{nombre: nombre, puntos: puntos, rol: rol}
    end)
  end

  @doc """
  Obtiene el ranking filtrado por compradores.
  """
  def ranking_compradores do
    Inmobiliaria.Servidor.obtener_ranking_por_rol(:cliente)
    |> Enum.map(fn {nombre, puntos} ->
      %{nombre: nombre, puntos: puntos}
    end)
  end

  @doc """
  Obtiene el ranking filtrado por vendedores.
  """
  def ranking_vendedores do
    Inmobiliaria.Servidor.obtener_ranking_por_rol(:vendedor)
    |> Enum.map(fn {nombre, puntos} ->
      %{nombre: nombre, puntos: puntos}
    end)
  end

  @doc """
  Obtiene el ranking filtrado por arrendadores.
  """
  def ranking_arrendadores do
    Inmobiliaria.Servidor.obtener_ranking_por_rol(:arrendador)
    |> Enum.map(fn {nombre, puntos} ->
      %{nombre: nombre, puntos: puntos}
    end)
  end

  @doc """
  Muestra el ranking formateado para mostrar en pantalla.
  """
  def mostrar_ranking(tipo \\ :global) do
    ranking = case tipo do
      :global -> ranking_global()
      :compradores -> ranking_compradores()
      :vendedores -> ranking_vendedores()
      :arrendadores -> ranking_arrendadores()
    end

    IO.puts("\n🏆 RANKING #{String.upcase(to_string(tipo))} 🏆")
    IO.puts(String.duplicate("─", 40))

    ranking
    |> Enum.with_index(1)
    |> Enum.each(fn {%{nombre: nombre, puntos: puntos}, posicion} ->
      medalla = case posicion do
        1 -> "🥇"
        2 -> "🥈"
        3 -> "🥉"
        _ -> "  "
      end
      IO.puts("#{medalla} #{posicion}. #{nombre} - #{puntos} puntos")
    end)

    IO.puts(String.duplicate("─", 40) <> "\n")
    ranking
  end
end
