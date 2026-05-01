# 🏎️ VWheel - Virtual Steering Wheel

Transforma tu smartphone Android en un volante de PC totalmente funcional con soporte para **Force Feedback (FFB)**, ideal para juegos de carreras y simuladores.

VWheel utiliza una conexión UDP de baja latencia entre una aplicación móvil (Flutter) y un servidor de Windows (C#) para emular un joystick virtual mediante vJoy.

## ✨ Características Principales
* **Baja Latencia:** Comunicación en tiempo real a través de tu red Wi-Fi local.
* **Force Feedback (FFB):** Siente la respuesta del juego en tu teléfono (vibración/respuesta háptica).
* **Fácil Configuración:** Autodescubrimiento o conexión rápida mediante IP.
* **Instalación Automatizada:** El instalador de PC incluye las dependencias necesarias de vJoy.

---

## 🛠️ Requisitos Previos
* Una PC con Windows 10/11.
* Un dispositivo Android.
* **Importante:** Ambos dispositivos deben estar conectados a la **misma red Wi-Fi**.

---

## 🚀 Instalación y Uso

### 1. Preparar la PC (Servidor)
1. Ve a la sección de [Releases](../../releases) de este repositorio.
2. Descarga el archivo `VWheel_Server_v1.0_Installer.exe`.
3. Ejecuta el instalador. Al finalizar, te pedirá instalar **vJoy** (el controlador virtual). Sigue los pasos y asegúrate de que se instale correctamente.
4. Abre **VWheel Receiver** en tu PC. *(Nota: Se recomienda ejecutarlo como Administrador).*

### 2. Preparar el Celular (Cliente)
1. En la misma sección de [Releases](../../releases), descarga el archivo `VWheel_Client_v1.0.apk`.
2. Pásalo a tu celular Android e instálalo (es posible que debas habilitar la instalación desde "Fuentes desconocidas").
3. Abre la aplicación **VWheel** en tu celular.

### 3. ¡A jugar!
* Una vez que ambas aplicaciones estén abiertas y en la misma red, el servidor detectará la conexión de tu celular automáticamente.
* Configura los controles dentro de tu juego favorito (asignando los ejes de giro a tu celular) y disfruta.

---

## 🔧 Solución de Problemas Frecuentes (Troubleshooting)

**❌ El Force Feedback (FFB) no funciona o el servidor muestra una "ALERTA"**
* **Solución 1:** Cierra el servidor VWheel, haz clic derecho sobre su icono y selecciona **"Ejecutar como Administrador"**. Esto permite que el programa tenga los permisos necesarios para interactuar con el driver.
* **Solución 2:** Asegúrate de que no tengas abierta la aplicación `vJoyConf` o `vJoyMonitor` en segundo plano, ya que bloquean el acceso al volante.
* **Solución 3:** Abre el programa "Configure vJoy" en tu PC, asegúrate de que la opción **Enable Effects** (FFB) esté marcada, y dale a Apply.

**❌ El celular no se conecta al servidor de PC**
* Verifica que tu red Wi-Fi esté configurada como "Privada" en Windows.
* Revisa que el Firewall de Windows no esté bloqueando VWheel o las conexiones UDP.
* Asegúrate de no tener una VPN activa en ninguno de los dos dispositivos.

---

## 👨‍💻 Autor
Creado por **Adi** (@ItsAdi916). 
Para comentarios, soporte o sugerencias, encuéntrame en X (Twitter).