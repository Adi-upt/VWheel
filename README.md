# 🏎️ VWheel - Virtual Steering Wheel

[🇬🇧 English](#-english-version) | [🇪🇸 Español](#-versión-en-español)

---

# 🇬🇧 English Version

Transform your Android smartphone into a fully functional PC steering wheel with **Universal Force Feedback (FFB)** support, ideal for racing games and simulators. 

VWheel uses a zero-latency, event-driven UDP connection between a mobile app (Flutter) and a Windows server (C#) to emulate a virtual joystick via vJoy.

## ✨ Key Features
* **Zero Latency Engine:** 250Hz event-driven network polling for an instantaneous 1:1 steering response.
* **Sensor Fusion:** Combines the Accelerometer and Gyroscope for smooth, drift-free, and highly accurate steering.
* **Universal Force Feedback (NEW v1.0.6):** Read direct telemetry from the Windows DirectInput API. Feel the difference between subtle track textures (short haptics) and heavy crashes or kerbs (heavy haptics) on your phone. Works with almost any simulator (Raceroom, Assetto Corsa, F1, etc.).
* **Custom UI Editor:** Build, edit, and save your own button/pedal layouts directly within the app.
* **SimHub Telemetry:** Live dashboard with Gear indicators and responsive Shift Lights.
* **Automated Setup:** The PC installer automatically includes and sets up the required vJoy dependencies.

## 🛠️ Prerequisites
* A PC running Windows 10/11.
* An Android device.
* **Important:** Both devices must be connected to the **same Wi-Fi network** (or use USB Tethering for absolute minimum latency).

## 🚀 Installation & Usage

### 1. Prepare the PC (Server)
1. Go to the [Releases](../../releases) section of this repository.
2. Download `VWheel_Server_v1.0.6_Installer.exe`.
3. Run the installer. At the end, it will prompt you to install **vJoy** (the virtual driver). Follow the steps to ensure it installs correctly.
4. Open the **VWheel Receiver** on your PC. *(Note: Running as Administrator is recommended).*
5. On the first launch, it will prompt you to configure vJoy. Set buttons to 32, **check "Enable Effects"** (Crucial for FFB), and hit Apply.

### 2. Prepare the Phone (Client)
1. From the [Releases](../../releases) section, download `VWheel_Mobile_v1.0.6.apk`.
2. Transfer it to your Android device and install it (you may need to allow installations from "Unknown Sources").
3. Open the **VWheel** app on your phone.

### 3. Start Driving!
* With both apps open on the same network, the server will automatically detect your phone.
* **For Force Feedback:** Ensure FFB/Vibration is **ENABLED** in your racing game settings, with a high intensity for the vJoy device.
* Bind your new virtual wheel axes and buttons inside your favorite racing game settings and enjoy!

## 🏎️ Telemetry Setup (Optional but Recommended)
To enable real-time dashboard data (RPM, Gear, Shift Lights) on your VWheel mobile app, VWheel connects seamlessly with **SimHub**, the industry standard for sim-racing telemetry.

**Step-by-step configuration:**
1. Download and install [SimHub](https://www.simhubdash.com/).
2. Open SimHub and go to **Settings** (left sidebar).
3. Select the **Custom UDP Telemetry Export** tab.
4. Check the box **Enable UDP Telemetry**.
5. Configure the connection exactly like this:
   * **Target IP:** `127.0.0.1`
   * **Target Port:** `11003`
   * **Update Rate:** `60Hz` (or `30Hz` for older routers)
   * **Message Template:** Copy and paste the exact formula below:
     ```text
     [DataCorePlugin.GameData.Gear];[DataCorePlugin.GameData.EngineRpm];[DataCorePlugin.GameData.CarSettings_MaxEngineRpm]
     ```
6. Click **Save/Apply**. 

That's it! Now, launch any of the 60+ games supported by SimHub, and VWheel will instantly display your live dashboard and shift lights.

## 🔧 Troubleshooting

**❌ Force Feedback (FFB) is not working or server shows an "ALERT"**
* **Solution 1:** Close the VWheel server, right-click its icon, and select **"Run as Administrator"**. This grants the program the necessary permissions to interact with the vJoy driver.
* **Solution 2:** Open the "Configure vJoy" program on your PC, ensure the **Enable Effects** (FFB) box is checked, and click Apply.
* **Solution 3:** Make sure you don't have `vJoyConf` or `vJoyMonitor` open in the background, as they block access to the steering wheel.

**❌ Phone won't connect to the PC server**
* Verify your Wi-Fi network is set to "Private" in Windows.
* Check that the Windows Firewall isn't blocking VWheel or UDP connections (Ports 11000, 11001, 11002).
* Ensure neither device has an active VPN.

---
---

# 🇪🇸 Versión en Español

Transforma tu smartphone Android en un volante de PC totalmente funcional con soporte para **Force Feedback (FFB) Universal**, ideal para juegos de carreras y simuladores.

VWheel utiliza una conexión UDP de cero latencia basada en eventos entre una aplicación móvil (Flutter) y un servidor de Windows (C#) para emular un joystick virtual mediante vJoy.

## ✨ Características Principales
* **Motor de Cero Latencia:** Transmisión de red a 250Hz basada en eventos para una respuesta 1:1 instantánea.
* **Fusión de Sensores:** Combina Acelerómetro y Giroscopio para un giro suave, preciso y sin desvíos (drift).
* **Force Feedback Universal (NUEVO v1.0.6):** Lee la telemetría directa desde la API DirectInput de Windows. Siente la diferencia entre la sutil textura de la pista (vibración corta) y los baches o choques fuertes (vibración pesada) en tu celular. Funciona con casi cualquier simulador (Raceroom, Assetto Corsa, F1, etc.).
* **Editor de Interfaz:** Crea, edita y guarda tus propios diseños de botones y pedales directamente en la app.
* **Telemetría SimHub:** Tablero en vivo con indicadores de marcha y luces LED (Shift Lights) responsivas.
* **Instalación Automatizada:** El instalador de PC configura automáticamente las dependencias necesarias de vJoy.

## 🛠️ Requisitos Previos
* Una PC con Windows 10/11.
* Un dispositivo Android.
* **Importante:** Ambos dispositivos deben estar conectados a la **misma red Wi-Fi** (o usar Anclaje a red USB para la latencia más baja posible).

## 🚀 Instalación y Uso

### 1. Preparar la PC (Servidor)
1. Ve a la sección de [Releases](../../releases) de este repositorio.
2. Descarga el archivo `VWheel_Server_v1.0.6_Installer.exe`.
3. Ejecuta el instalador. Al finalizar, te pedirá instalar **vJoy** (el controlador virtual). Sigue los pasos y asegúrate de que se instale correctamente.
4. Abre **VWheel Receiver** en tu PC. *(Nota: Se recomienda ejecutarlo como Administrador).*
5. En el primer inicio, te pedirá configurar vJoy. Pon los botones en 32, **marca "Enable Effects"** (Crucial para FFB) y haz clic en Apply.

### 2. Preparar el Celular (Cliente)
1. En la misma sección de [Releases](../../releases), descarga el archivo `VWheel_Mobile_v1.0.6.apk`.
2. Pásalo a tu celular Android e instálalo (es posible que debas habilitar la instalación desde "Fuentes desconocidas").
3. Abre la aplicación **VWheel** en tu celular.

### 3. ¡A jugar!
* Una vez que ambas aplicaciones estén abiertas y en la misma red, el servidor detectará la conexión de tu celular automáticamente.
* **Para el Force Feedback:** Asegúrate de que las opciones de vibración/FFB estén **ACTIVADAS** en los ajustes de tu juego, con una intensidad alta para el dispositivo vJoy.
* Configura los ejes y botones dentro de los ajustes de tu juego de carreras favorito y disfruta.

## 🏎️ Configuración de Telemetría (Opcional pero Recomendado)
Para activar los datos en tiempo real (RPM, Marcha, Luces LED) en tu celular, VWheel se conecta de forma nativa con **SimHub**, el estándar de la industria para telemetría en simuladores.

**Configuración paso a paso:**
1. Descarga e instala [SimHub](https://www.simhubdash.com/).
2. Abre SimHub y ve a **Settings** (menú izquierdo).
3. Selecciona la pestaña **Custom UDP Telemetry Export**.
4. Marca la casilla **Enable UDP Telemetry**.
5. Configura la conexión exactamente así:
   * **Target IP:** `127.0.0.1`
   * **Target Port:** `11003`
   * **Update Rate:** `60Hz` (o `30Hz` si tu Wi-Fi es inestable)
   * **Message Template:** Copia y pega exactamente esta fórmula matemática:
     ```text
     [DataCorePlugin.GameData.Gear];[DataCorePlugin.GameData.EngineRpm];[DataCorePlugin.GameData.CarSettings_MaxEngineRpm]
     ```
6. Haz clic en **Save/Apply**. 

¡Listo! Inicia cualquiera de los más de 60 juegos soportados por SimHub y tu tablero de VWheel cobrará vida al instante.

## 🔧 Solución de Problemas Frecuentes (Troubleshooting)

**❌ El Force Feedback (FFB) no funciona o el servidor muestra una "ALERTA"**
* **Solución 1:** Cierra el servidor VWheel, haz clic derecho sobre su icono y selecciona **"Ejecutar como Administrador"**. Esto permite que el programa tenga los permisos necesarios para interactuar con el driver.
* **Solución 2:** Abre el programa "Configure vJoy" en tu PC, asegúrate de que la opción **Enable Effects** (FFB) esté marcada, y dale a Apply.
* **Solución 3:** Asegúrate de que no tengas abierta la aplicación `vJoyConf` o `vJoyMonitor` en segundo plano, ya que bloquean el acceso al volante.

**❌ El celular no se conecta al servidor de PC**
* Verifica que tu red Wi-Fi esté configurada como "Privada" en Windows.
* Revisa que el Firewall de Windows no esté bloqueando VWheel o las conexiones UDP (Puertos 11000, 11001, 11002).
* Asegúrate de no tener una VPN activa en ninguno de los dos dispositivos.

---

## 👨‍💻 Author / Autor
Created by **Adi** (@ItsAdi916).  
For feedback, support, or suggestions, find me on X (Twitter).