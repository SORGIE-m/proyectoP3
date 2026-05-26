defmodule Inmobiliaria.ValidadorUbicaciones do
  @moduledoc """
  Valida que las ubicaciones de las propiedades
  estén en la lista de ubicaciones permitidas.
  """

  @ruta_archivo "data/locations.dat"

  @doc """
  Verifica si una ubicación es válida (sin distinción mayúsculas/minúsculas).
  """
  def ubicacion_valida?(ubicacion) do
    ubicacion_normalizada = ubicacion |> String.trim() |> String.downcase()
    ubicacion_normalizada in ubicaciones_normalizadas()
  end

  @doc """
  Obtiene la lista de ubicaciones permitidas.
  """
  def ubicaciones_permitidas do
    case File.read(@ruta_archivo) do
      {:ok, contenido} ->
        contenido
        |> String.split("\n", trim: true)
        |> Enum.map(&String.trim/1)

      {:error, _} ->
        [
          "Armenia",
          "Calarcá",
          "Quimbaya",
          "Montenegro",
          "La Tebaida",
          "Circasia",
          "Filandia",
          "Salento"
        ]
    end
  end

  @doc """
  Muestra las ubicaciones disponibles.
  """
  def mostrar_ubicaciones do
    IO.puts("\n📍 UBICACIONES DISPONIBLES 📍")
    IO.puts(String.duplicate("─", 30))

    ubicaciones_permitidas()
    |> Enum.each(fn ubicacion -> IO.puts("  • #{ubicacion}") end)

    IO.puts(String.duplicate("─", 30) <> "\n")
  end

  defp ubicaciones_normalizadas do
    ubicaciones_permitidas()
    |> Enum.map(&String.downcase/1)
  end
end
