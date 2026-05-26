defmodule Inmobiliaria.Propiedad do
  @moduledoc """
  GenServer que representa una propiedad individual.
  Maneja su estado y las operaciones sobre ella de forma concurrente.
  """
  use GenServer

  # ─── API Pública ───
  def start_link(propiedad) do
    GenServer.start_link(__MODULE__, propiedad)
  end

  def obtener_info(pid) do
    GenServer.call(pid, :obtener_info)
  rescue
    _ -> nil
  end

  def actualizar_estado(pid, nuevo_estado) do
    GenServer.call(pid, {:actualizar_estado, nuevo_estado})
  end

  def comprar(pid, comprador) do
    GenServer.call(pid, {:comprar, comprador})
  end

  def arrendar(pid, arrendatario) do
    GenServer.call(pid, {:arrendar, arrendatario})
  end

  def verificar_disponibilidad(pid) do
    GenServer.call(pid, :verificar_disponibilidad)
  end

  # ─── Callbacks del GenServer ───
  @impl true
  def init(propiedad) do
    {:ok, propiedad}
  end

  @impl true
  def handle_call(:obtener_info, _de, estado) do
    {:reply, estado, estado}
  end

  @impl true
  def handle_call({:actualizar_estado, nuevo_estado}, _de, estado) do
    {:reply, :ok, %{estado | estado: nuevo_estado}}
  end

  @impl true
  def handle_call({:comprar, _comprador}, _de, estado) do
    if estado.modalidad == :venta && estado.estado == :disponible do
      {:reply, {:ok, estado.precio, estado.propietario}, %{estado | estado: :vendida}}
    else
      {:reply, {:error, :no_disponible}, estado}
    end
  end

  @impl true
  def handle_call({:arrendar, _arrendatario}, _de, estado) do
    if estado.modalidad == :arriendo && estado.estado == :disponible do
      {:reply, {:ok, estado.precio, estado.propietario}, %{estado | estado: :arrendada}}
    else
      {:reply, {:error, :no_disponible}, estado}
    end
  end

  @impl true
  def handle_call(:verificar_disponibilidad, _de, estado) do
    disponible = estado.estado == :disponible
    {:reply, disponible, estado}
  end
end
