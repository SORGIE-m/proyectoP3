import tkinter as tk
from tkinter import ttk, messagebox
import os
import time

PROYECTO_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(PROYECTO_DIR, "data")

# ─── Paleta de colores ───
BG_DARK = "#0f172a"
BG_CARD = "#1e293b"
BG_INPUT = "#334155"
TEXT_PRIMARY = "#f1f5f9"
TEXT_SECONDARY = "#94a3b8"
ACCENT_BLUE = "#3b82f6"
ACCENT_GREEN = "#10b981"
ACCENT_RED = "#ef4444"
ACCENT_YELLOW = "#f59e0b"
BORDER = "#475569"

def enviar_comando(comando_str):
    cmd_path = os.path.join(DATA_DIR, "comando.txt")
    resp_path = os.path.join(DATA_DIR, "respuesta.txt")
    
    if os.path.exists(resp_path):
        os.remove(resp_path)
    
    with open(cmd_path, "w", encoding="utf-8") as f:
        f.write(comando_str.strip())
    
    for _ in range(30):
        time.sleep(0.2)
        if os.path.exists(resp_path):
            with open(resp_path, "r", encoding="utf-8") as f:
                resp = f.read().strip()
            os.remove(resp_path)
            return resp
    
    return "ERROR:timeout"

def crear_boton(parent, texto, comando, color=ACCENT_BLUE, ancho=20, altura=2):
    return tk.Button(parent, text=texto, font=("Segoe UI", 11, "bold"),
                     bg=color, fg="white", activebackground=color,
                     activeforeground="white", relief="flat",
                     cursor="hand2", width=ancho, height=altura,
                     command=comando)

def crear_entry_simple(parent, placeholder="", show=None, width=30):
    entry = tk.Entry(parent, font=("Segoe UI", 12), bg=BG_INPUT, fg=TEXT_PRIMARY,
                     insertbackground=TEXT_PRIMARY, relief="flat", width=width,
                     show=show)
    if placeholder:
        entry.insert(0, placeholder)
        entry.configure(fg=TEXT_SECONDARY)
        def on_focus_in(e):
            if entry.get() == placeholder:
                entry.delete(0, "end")
                entry.configure(fg=TEXT_PRIMARY)
        def on_focus_out(e):
            if not entry.get():
                entry.insert(0, placeholder)
                entry.configure(fg=TEXT_SECONDARY)
        entry.bind("<FocusIn>", on_focus_in)
        entry.bind("<FocusOut>", on_focus_out)
    return entry

def parsear_propiedad(texto):
    campos = {}
    for campo in ["id", "tipo", "modalidad", "ubicacion", "precio", "area", "habitaciones", "baños", "descripcion", "propietario", "estado"]:
        patron = campo + ": "
        if patron in texto:
            inicio = texto.find(patron) + len(patron)
            fin = texto.find(",", inicio)
            if fin == -1:
                fin = texto.find("}", inicio)
            valor = texto[inicio:fin].strip().strip('"').lstrip(":")
            campos[campo] = valor
    return campos

class InmobiliariaApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Inmobiliaria Virtual")
        self.root.geometry("1100x700")
        self.root.configure(bg=BG_DARK)
        self.root.minsize(900, 600)
        self.usuario_actual = None
        self.rol_actual = None
        
        style = ttk.Style()
        style.theme_use("clam")
        style.configure("TNotebook", background=BG_DARK, borderwidth=0)
        style.configure("TNotebook.Tab", padding=[30, 10], font=("Segoe UI", 11), background=BG_DARK, foreground=TEXT_PRIMARY)
        style.map("TNotebook.Tab", background=[("selected", BG_CARD)], foreground=[("selected", ACCENT_BLUE)])
        
        self.mostrar_login()
    
    def mostrar_login(self):
        self.limpiar_ventana()
        
        left = tk.Frame(self.root, bg=ACCENT_BLUE, width=400)
        left.pack(side="left", fill="both")
        left.pack_propagate(False)
        
        tk.Label(left, text="🏠", font=("Segoe UI", 60), bg=ACCENT_BLUE, fg="white").pack(pady=(200, 0))
        tk.Label(left, text="Inmobiliaria\nVirtual", font=("Segoe UI", 28, "bold"), bg=ACCENT_BLUE, fg="white", justify="center").pack(pady=10)
        tk.Label(left, text="El futuro de tu hogar empieza aquí", font=("Segoe UI", 12), bg=ACCENT_BLUE, fg="white").pack()
        
        right = tk.Frame(self.root, bg=BG_DARK)
        right.pack(side="right", fill="both", expand=True)
        
        form = tk.Frame(right, bg=BG_DARK)
        form.place(relx=0.5, rely=0.5, anchor="center")
        
        tk.Label(form, text="Iniciar Sesión", font=("Segoe UI", 22, "bold"), fg=TEXT_PRIMARY, bg=BG_DARK).pack(pady=(0, 30))
        
        tk.Label(form, text="Usuario", font=("Segoe UI", 11), fg=TEXT_SECONDARY, bg=BG_DARK).pack(anchor="w")
        self.entry_usuario = crear_entry_simple(form)
        self.entry_usuario.pack(ipady=8, pady=(5, 15))
        
        tk.Label(form, text="Contraseña", font=("Segoe UI", 11), fg=TEXT_SECONDARY, bg=BG_DARK).pack(anchor="w")
        self.entry_password = crear_entry_simple(form, show="•")
        self.entry_password.pack(ipady=8, pady=(5, 25))
        
        crear_boton(form, "Iniciar Sesión", self.login, ACCENT_BLUE).pack(pady=5)
        crear_boton(form, "Crear Cuenta", self.mostrar_registro, BG_CARD).pack(pady=5)
    
    def mostrar_registro(self):
        self.limpiar_ventana()
        
        left = tk.Frame(self.root, bg=ACCENT_GREEN, width=400)
        left.pack(side="left", fill="both")
        left.pack_propagate(False)
        
        tk.Label(left, text="📝", font=("Segoe UI", 60), bg=ACCENT_GREEN, fg="white").pack(pady=(200, 0))
        tk.Label(left, text="Crear Cuenta", font=("Segoe UI", 28, "bold"), bg=ACCENT_GREEN, fg="white").pack(pady=10)
        tk.Label(left, text="Únete a nuestra comunidad", font=("Segoe UI", 12), bg=ACCENT_GREEN, fg="white").pack()
        
        right = tk.Frame(self.root, bg=BG_DARK)
        right.pack(side="right", fill="both", expand=True)
        
        form = tk.Frame(right, bg=BG_DARK)
        form.place(relx=0.5, rely=0.5, anchor="center")
        
        tk.Label(form, text="Registro", font=("Segoe UI", 22, "bold"), fg=TEXT_PRIMARY, bg=BG_DARK).pack(pady=(0, 30))
        
        tk.Label(form, text="Usuario", font=("Segoe UI", 11), fg=TEXT_SECONDARY, bg=BG_DARK).pack(anchor="w")
        entry_user = crear_entry_simple(form)
        entry_user.pack(ipady=8, pady=(5, 15))
        
        tk.Label(form, text="Contraseña", font=("Segoe UI", 11), fg=TEXT_SECONDARY, bg=BG_DARK).pack(anchor="w")
        entry_pass = crear_entry_simple(form, show="•")
        entry_pass.pack(ipady=8, pady=(5, 15))
        
        tk.Label(form, text="Rol", font=("Segoe UI", 11), fg=TEXT_SECONDARY, bg=BG_DARK).pack(anchor="w")
        rol_var = tk.StringVar(value="cliente")
        roles_frame = tk.Frame(form, bg=BG_DARK)
        roles_frame.pack(pady=(5, 25))
        for rol in ["cliente", "vendedor", "arrendador"]:
            tk.Radiobutton(roles_frame, text=rol.capitalize(), variable=rol_var, value=rol,
                          font=("Segoe UI", 10), fg=TEXT_PRIMARY, bg=BG_DARK,
                          selectcolor=BG_CARD, activebackground=BG_DARK,
                          activeforeground=ACCENT_BLUE).pack(side="left", padx=10)
        
        def registrar():
            user = entry_user.get()
            passw = entry_pass.get()
            rol = rol_var.get()
            if not user or not passw:
                messagebox.showwarning("Atención", "Complete todos los campos")
                return
            resp = enviar_comando(f"registrar|{user}|{passw}|{rol}")
            if resp.startswith("OK:"):
                messagebox.showinfo("✓ Éxito", "Usuario registrado correctamente")
                self.mostrar_login()
            else:
                messagebox.showerror("Error", resp)
        
        crear_boton(form, "Registrarse", registrar, ACCENT_GREEN).pack(pady=5)
        crear_boton(form, "Volver al Login", self.mostrar_login, BG_CARD).pack(pady=5)
    
    def login(self):
        usuario = self.entry_usuario.get()
        password = self.entry_password.get()
        if not usuario or not password:
            messagebox.showwarning("Atención", "Complete todos los campos")
            return
        resp = enviar_comando(f"login|{usuario}|{password}")
        if resp.startswith("OK:"):
            self.usuario_actual = usuario
            resp_lower = resp.lower()
            if "cliente" in resp_lower: self.rol_actual = "cliente"
            elif "vendedor" in resp_lower: self.rol_actual = "vendedor"
            elif "arrendador" in resp_lower: self.rol_actual = "arrendador"
            else: self.rol_actual = "desconocido"
            self.mostrar_dashboard()
        else:
            messagebox.showerror("Error", resp)
    
    def mostrar_dashboard(self):
        self.limpiar_ventana()
        
        top = tk.Frame(self.root, bg=BG_CARD, height=60)
        top.pack(fill="x")
        top.pack_propagate(False)
        
        rol_icono = {"cliente": "👤", "vendedor": "🏠", "arrendador": "🔑"}.get(self.rol_actual, "👤")
        tk.Label(top, text=f"{rol_icono}  {self.usuario_actual}  ·  {self.rol_actual.capitalize()}",
                font=("Segoe UI", 13, "bold"), fg=TEXT_PRIMARY, bg=BG_CARD).pack(side="left", padx=25, pady=15)
        
        crear_boton(top, "Cerrar Sesión", self.cerrar_sesion, ACCENT_RED, ancho=15, altura=1).pack(side="right", padx=25, pady=12)
        
        notebook = ttk.Notebook(self.root)
        notebook.pack(fill="both", expand=True, padx=20, pady=15)
        
        tab_props = tk.Frame(notebook, bg=BG_DARK)
        notebook.add(tab_props, text="  🏠  Propiedades  ")
        self.crear_tab_propiedades(tab_props)
        
        tab_rank = tk.Frame(notebook, bg=BG_DARK)
        notebook.add(tab_rank, text="  🏆  Ranking  ")
        self.crear_tab_ranking(tab_rank)
    
    def crear_tab_propiedades(self, parent):
        header = tk.Frame(parent, bg=BG_DARK)
        header.pack(fill="x", pady=(15, 25))
        
        if self.rol_actual in ["vendedor", "arrendador"]:
            crear_boton(header, "+  Publicar Propiedad", self.mostrar_publicar, ACCENT_GREEN, ancho=22).pack(side="right", padx=10)
        
        tk.Label(header, text="Propiedades Disponibles", font=("Segoe UI", 18, "bold"), fg=TEXT_PRIMARY, bg=BG_DARK).pack(side="left")
        
        canvas = tk.Canvas(parent, bg=BG_DARK, highlightthickness=0)
        scrollbar = ttk.Scrollbar(parent, orient="vertical", command=canvas.yview)
        self.lista_propiedades = tk.Frame(canvas, bg=BG_DARK)
        
        self.lista_propiedades.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=self.lista_propiedades, anchor="nw", tags="inner")
        
        def config_width(event):
            canvas.itemconfig("inner", width=event.width)
        canvas.bind("<Configure>", config_width)
        
        canvas.configure(yscrollcommand=scrollbar.set)
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        
        def on_mousewheel(event):
            canvas.yview_scroll(int(-1*(event.delta/120)), "units")
        canvas.bind("<Enter>", lambda e: canvas.bind_all("<MouseWheel>", on_mousewheel))
        canvas.bind("<Leave>", lambda e: canvas.unbind_all("<MouseWheel>"))
        
        self.cargar_propiedades()
    
    def cargar_propiedades(self):
        for widget in self.lista_propiedades.winfo_children():
            widget.destroy()
        
        resp = enviar_comando("listar|")
        if resp.startswith("OK:"):
            contenido = resp[3:]
            if contenido == "[]":
                tk.Label(self.lista_propiedades, text="🔍  No hay propiedades publicadas aún", 
                        font=("Segoe UI", 13), fg=TEXT_SECONDARY, bg=BG_DARK).pack(pady=50)
            else:
                props = [p for p in contenido.split("%Inmobiliaria.TiposDatos.Propiedad{") if p.strip() and "id:" in p]
                if not props:
                    tk.Label(self.lista_propiedades, text="🔍  No hay propiedades disponibles", 
                            font=("Segoe UI", 13), fg=TEXT_SECONDARY, bg=BG_DARK).pack(pady=50)
                for parte in props:
                    self._mostrar_propiedad_card(parte.strip())
        else:
            tk.Label(self.lista_propiedades, text="Error al cargar propiedades", 
                    font=("Segoe UI", 13), fg=ACCENT_RED, bg=BG_DARK).pack(pady=50)
    
    def _mostrar_propiedad_card(self, texto):
        campos = parsear_propiedad(texto)
        if not campos.get("id") or not campos.get("tipo"):
            return
        
        card = tk.Frame(self.lista_propiedades, bg=BG_CARD, padx=20, pady=15, highlightbackground=BORDER, highlightthickness=1)
        card.pack(fill="x", pady=8, padx=10)
        
        tipo = campos.get("tipo", "").upper()
        modalidad = campos.get("modalidad", "").upper()
        ubicacion = campos.get("ubicacion", "")
        precio = campos.get("precio", "0")
        area = campos.get("area", "0")
        hab = campos.get("habitaciones", "0")
        banos = campos.get("baños", "0")
        propietario = campos.get("propietario", "")
        estado = campos.get("estado", "")
        id_prop = campos.get("id", "")
        
        try:
            precio_f = int(precio)
            precio_str = f"${precio_f:,.0f}".replace(",", ".")
        except:
            precio_str = f"${precio}"
        
        icono = {"CASA": "🏠", "APARTAMENTO": "🏢", "OFICINA": "🏬", "LOTE": "🌳"}.get(tipo, "🏠")
        estado_color = ACCENT_GREEN if "disponible" in estado else ACCENT_RED
        
        tk.Label(card, text=precio_str, font=("Segoe UI", 20, "bold"), fg=ACCENT_GREEN, bg=BG_CARD).pack(anchor="w")
        
        titulo = f"{icono}  {tipo} en {ubicacion}"
        tk.Label(card, text=titulo, font=("Segoe UI", 13, "bold"), fg=TEXT_PRIMARY, bg=BG_CARD).pack(anchor="w", pady=(5, 10))
        
        detalles = f"📐 {area} m²    🛏 {hab} hab    🚿 {banos} baños    📋 {modalidad}"
        tk.Label(card, text=detalles, font=("Segoe UI", 10), fg=TEXT_SECONDARY, bg=BG_CARD).pack(anchor="w")
        
        footer = tk.Frame(card, bg=BG_CARD)
        footer.pack(fill="x", pady=(10, 0))
        
        tk.Label(footer, text=f"Publicado por {propietario}", font=("Segoe UI", 9), fg=TEXT_SECONDARY, bg=BG_CARD).pack(side="left")
        
        estado_texto = "✓ Disponible" if "disponible" in estado else estado.replace("_", " ").capitalize()
        tk.Label(footer, text=estado_texto, font=("Segoe UI", 9, "bold"), fg=estado_color, bg=BG_CARD).pack(side="right")
        
        if self.rol_actual == "cliente" and "disponible" in estado:
            if modalidad == "VENTA":
                crear_boton(card, "💰 Comprar", lambda p=id_prop: self.comprar(p), ACCENT_GREEN, ancho=14, altura=1).pack(anchor="e", pady=(10, 0))
            elif modalidad == "ARRIENDO":
                crear_boton(card, "🔑 Arrendar", lambda p=id_prop: self.arrendar(p), ACCENT_BLUE, ancho=14, altura=1).pack(anchor="e", pady=(10, 0))
    
    def comprar(self, id_propiedad):
        if messagebox.askyesno("Confirmar", "¿Desea comprar esta propiedad?"):
            resp = enviar_comando(f"comprar|{id_propiedad}|{self.usuario_actual}")
            if resp.startswith("OK:"):
                messagebox.showinfo("✓ Éxito", "Propiedad comprada con éxito")
                self.cargar_propiedades()
            else:
                messagebox.showerror("Error", resp)
    
    def arrendar(self, id_propiedad):
        if messagebox.askyesno("Confirmar", "¿Desea arrendar esta propiedad?"):
            resp = enviar_comando(f"arrendar|{id_propiedad}|{self.usuario_actual}")
            if resp.startswith("OK:"):
                messagebox.showinfo("✓ Éxito", "Propiedad arrendada con éxito")
                self.cargar_propiedades()
            else:
                messagebox.showerror("Error", resp)
    
    def mostrar_publicar(self):
        ventana = tk.Toplevel(self.root)
        ventana.title("Publicar Propiedad")
        ventana.geometry("520x700")
        ventana.configure(bg=BG_DARK)
        ventana.minsize(450, 600)
        
        canvas = tk.Canvas(ventana, bg=BG_DARK, highlightthickness=0)
        scrollbar = ttk.Scrollbar(ventana, orient="vertical", command=canvas.yview)
        contenido = tk.Frame(canvas, bg=BG_DARK)
        
        contenido.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=contenido, anchor="nw", tags="inner")
        
        def config_width(event):
            canvas.itemconfig("inner", width=event.width)
        canvas.bind("<Configure>", config_width)
        
        canvas.configure(yscrollcommand=scrollbar.set)
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        
        def on_mousewheel(event):
            canvas.yview_scroll(int(-1*(event.delta/120)), "units")
        canvas.bind("<Enter>", lambda e: canvas.bind_all("<MouseWheel>", on_mousewheel))
        canvas.bind("<Leave>", lambda e: canvas.unbind_all("<MouseWheel>"))
        
        tk.Label(contenido, text="Nueva Propiedad", font=("Segoe UI", 18, "bold"), fg=TEXT_PRIMARY, bg=BG_DARK).pack(pady=20)
        
        valores = {}
        
        for label, opciones in [
            ("Tipo", ["casa", "apartamento", "oficina", "lote"]),
            ("Modalidad", ["venta", "arriendo"]),
            ("Ubicación", ["Armenia", "Calarca", "Quimbaya", "Montenegro", "La Tebaida", "Circasia", "Filandia", "Salento"]),
        ]:
            tk.Label(contenido, text=label, font=("Segoe UI", 11), fg=TEXT_SECONDARY, bg=BG_DARK).pack(anchor="w", padx=40, pady=(10, 2))
            var = tk.StringVar(value=opciones[0])
            cmb = ttk.Combobox(contenido, textvariable=var, values=opciones, state="readonly", font=("Segoe UI", 11), width=35)
            cmb.pack(padx=40, pady=2)
            valores[label] = var
        
        for label, default in [("Precio ($)", "0"), ("Área (m²)", "0"), ("Habitaciones", "0"), ("Baños", "0")]:
            tk.Label(contenido, text=label, font=("Segoe UI", 11), fg=TEXT_SECONDARY, bg=BG_DARK).pack(anchor="w", padx=40, pady=(10, 2))
            entry = tk.Entry(contenido, font=("Segoe UI", 11), bg=BG_INPUT, fg=TEXT_PRIMARY, insertbackground=TEXT_PRIMARY, relief="flat", width=37)
            entry.insert(0, default)
            entry.pack(padx=40, ipady=6)
            valores[label] = entry
        
        tk.Label(contenido, text="Descripción", font=("Segoe UI", 11), fg=TEXT_SECONDARY, bg=BG_DARK).pack(anchor="w", padx=40, pady=(10, 2))
        entry_desc = tk.Text(contenido, font=("Segoe UI", 11), bg=BG_INPUT, fg=TEXT_PRIMARY, relief="flat", width=37, height=3)
        entry_desc.pack(padx=40)
        
        def publicar():
            datos = [
                valores["Tipo"].get(),
                valores["Modalidad"].get(),
                valores["Ubicación"].get(),
                valores["Precio ($)"].get(),
                valores["Área (m²)"].get(),
                valores["Habitaciones"].get(),
                valores["Baños"].get(),
                entry_desc.get("1.0", "end-1c").replace("\n", " "),
                self.usuario_actual
            ]
            resp = enviar_comando("publicar|" + "|".join(datos))
            if resp.startswith("OK:"):
                messagebox.showinfo("✓ Éxito", "Propiedad publicada correctamente")
                ventana.destroy()
                self.cargar_propiedades()
            else:
                messagebox.showerror("Error", resp[:300])
        
        crear_boton(contenido, "Publicar Propiedad", publicar, ACCENT_GREEN).pack(pady=25)
    
    def crear_tab_ranking(self, parent):
        tk.Label(parent, text="Ranking de Usuarios", font=("Segoe UI", 18, "bold"), fg=TEXT_PRIMARY, bg=BG_DARK).pack(pady=15)
        
        # Variable de filtro
        filtro_actual = tk.StringVar(value="global")
        
        # Frame para los botones de filtro
        filtros_frame = tk.Frame(parent, bg=BG_DARK)
        filtros_frame.pack(pady=10)
        
        # Frame para los resultados
        self.ranking_frame = tk.Frame(parent, bg=BG_DARK)
        self.ranking_frame.pack(fill="both", expand=True, padx=50, pady=20)
        
        def actualizar():
            for widget in self.ranking_frame.winfo_children():
                widget.destroy()
            
            filtro = filtro_actual.get()
            comando = f"ranking_{filtro}|" if filtro != "global" else "ranking|"
            
            resp = enviar_comando(comando)
            if resp.startswith("OK:"):
                contenido = resp[3:]
                if contenido and contenido.startswith("[") and contenido.endswith("]"):
                    items_str = contenido[1:-1]
                    if items_str.strip():
                        items = items_str.split("}, {")
                        for i, item in enumerate(items):
                            item = item.strip().strip("{").strip("}")
                            partes = item.split(", ")
                            nombre, puntos, rol = "", "0", ""
                            for p in partes:
                                if p.startswith('"'): nombre = p.strip('"')
                                elif p.startswith(":"): rol = p[1:]
                                elif p.lstrip("-").isdigit(): puntos = p
                            
                            medallas = ["🥇", "🥈", "🥉"]
                            medalla = medallas[i] if i < 3 else "  "
                            
                            if i == 0:
                                bg_color = "#1a3a2a"
                                fg_nombre = ACCENT_GREEN
                            else:
                                bg_color = BG_CARD
                                fg_nombre = TEXT_PRIMARY
                            
                            row = tk.Frame(self.ranking_frame, bg=bg_color, padx=20, pady=12)
                            row.pack(fill="x", pady=4)
                            
                            tk.Label(row, text=f"{medalla}  {i+1}", font=("Segoe UI", 16, "bold"), 
                                    fg=ACCENT_YELLOW if i < 3 else TEXT_SECONDARY, bg=bg_color).pack(side="left")
                            tk.Label(row, text=nombre, font=("Segoe UI", 14, "bold"), 
                                    fg=fg_nombre, bg=bg_color).pack(side="left", padx=15)
                            tk.Label(row, text=f"{puntos} pts", font=("Segoe UI", 13), 
                                    fg=ACCENT_BLUE, bg=bg_color).pack(side="right")
                            tk.Label(row, text=rol, font=("Segoe UI", 10), 
                                    fg=TEXT_SECONDARY, bg=bg_color).pack(side="right", padx=10)
                    else:
                        tk.Label(self.ranking_frame, text="Aún no hay usuarios registrados", 
                                font=("Segoe UI", 13), fg=TEXT_SECONDARY, bg=BG_DARK).pack(pady=40)
            else:
                tk.Label(self.ranking_frame, text="Error al cargar el ranking", 
                        font=("Segoe UI", 13), fg=ACCENT_RED, bg=BG_DARK).pack(pady=40)
        
        def cambiar_filtro():
            actualizar()
        
        for texto, valor in [("🌍 Global", "global"), ("👤 Compradores", "compradores"), 
                              ("🏠 Vendedores", "vendedores"), ("🔑 Arrendadores", "arrendadores")]:
            tk.Radiobutton(filtros_frame, text=texto, variable=filtro_actual, value=valor,
                          font=("Segoe UI", 10), fg=TEXT_PRIMARY, bg=BG_DARK,
                          selectcolor=BG_CARD, activebackground=BG_DARK,
                          activeforeground=ACCENT_BLUE, command=cambiar_filtro).pack(side="left", padx=10)
        
        actualizar()
    
    def cerrar_sesion(self):
        self.usuario_actual = None
        self.rol_actual = None
        self.mostrar_login()
    
    def limpiar_ventana(self):
        for widget in self.root.winfo_children():
            widget.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = InmobiliariaApp(root)
    root.mainloop()