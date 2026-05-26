defmodule Inmobiliaria.TiposDatos do
  @moduledoc """
  Definición de estructuras de datos compartidas en todo el sistema.
  """

  defmodule Usuario do
    defstruct [
      :nombre_usuario,
      :contraseña_hash,
      :rol,          # :cliente, :vendedor, :arrendador
      :puntos        # entero
    ]
  end

  defmodule Propiedad do
    defstruct [
      :id,
      :tipo,         # :casa, :apartamento, :oficina, :lote
      :modalidad,    # :venta, :arriendo
      :ubicacion,
      :precio,
      :area,
      :habitaciones,
      :baños,
      :descripcion,
      :propietario,  # nombre_usuario del publicador
      :estado        # :disponible, :vendida, :arrendada, :reservada
    ]
  end

  defmodule Mensaje do
    defstruct [
      :id,
      :de,           # nombre_usuario del remitente
      :para,         # nombre_usuario del destinatario
      :id_propiedad,
      :contenido,
      :fecha_hora
    ]
  end

  defmodule Transaccion do
    defstruct [
      :fecha,
      :cliente,
      :responsable,  # vendedor o arrendador
      :id_propiedad,
      :tipo,          # :compra, :arriendo
      :ubicacion,
      :precio,
      :estado
    ]
  end
end
