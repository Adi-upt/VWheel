using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Threading.Tasks;
using System.Windows.Forms;
using vJoyInterfaceWrap;

namespace VWheel
{
    

    public partial class MainForm : Form
    {
        private UdpClient udpServer;
        private bool isListening = false;
        private bool isBroadcasting = false;

        private vJoy joystick;
        private uint deviceId = 1;
        private bool isVJoyAcquired = false;
        private DateTime lastPacketTime;

        private IPEndPoint lastPhoneEP = null;
        private vJoy.FfbCbFunc ffbCallback;

        // Variables de Idioma
        private Label lblLangToggle;
        private string langFilePath = "vwheel_lang.txt";

        // --- NUEVO: Variables para el System Tray ---
        private NotifyIcon trayIcon;
        private ContextMenuStrip trayMenu;
        private bool isRealExit = false;

        public MainForm()
        {
            InitializeComponent();
            this.Text = "VWheel Receiver - Server";
            joystick = new vJoy();
            ffbCallback = new vJoy.FfbCbFunc(OnFFBEvent);

            lblAbout.UseMnemonic = false;

            if (File.Exists(langFilePath))
            {
                Tr.CurrentLang = File.ReadAllText(langFilePath).Trim() == "es" ? "es" : "en";
            }

            lblAbout.Cursor = Cursors.Hand;
            lblAbout.Click += lblAbout_Click;

            lblLangToggle = new Label();
            lblLangToggle.AutoSize = true;
            lblLangToggle.Cursor = Cursors.Hand;
            lblLangToggle.ForeColor = System.Drawing.Color.DodgerBlue;
            lblLangToggle.Font = new System.Drawing.Font(lblAbout.Font, System.Drawing.FontStyle.Bold);
            lblLangToggle.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            lblLangToggle.Click += LblLangToggle_Click;
            this.Controls.Add(lblLangToggle);

            // Conecta el botón 'X' de Windows con nuestra función de intercepción
            this.FormClosing += MainForm_FormClosing;

            // --- NUEVO: Configuración del Icono Oculto (Tray) ---
            ConfigurarSystemTray();

            UpdateUITexts();
        }

        // Configura el icono junto al reloj de Windows
        private void ConfigurarSystemTray()
        {
            trayMenu = new ContextMenuStrip();
            trayMenu.Items.Add(Tr.Get("exit_app"), null, OnTrayExitClick); // Se añade el botón de salir

            trayIcon = new NotifyIcon();
            trayIcon.Text = "VWheel Server";
            trayIcon.Icon = this.Icon; // Usa el icono por defecto de la app
            trayIcon.ContextMenuStrip = trayMenu;
            trayIcon.Visible = true;

            // Si hacen doble clic en el icono pequeño, la ventana vuelve a aparecer
            trayIcon.DoubleClick += TrayIcon_DoubleClick;
        }

        // El verdadero botón para matar la aplicación por completo
        private void OnTrayExitClick(object sender, EventArgs e)
        {
            isRealExit = true; // Levantamos la bandera de cierre total
            Application.Exit();
        }

        // Restaura la ventana
        private void TrayIcon_DoubleClick(object sender, EventArgs e)
        {
            this.Show();
            this.WindowState = FormWindowState.Normal;
            this.BringToFront(); // Trae la ventana al frente
        }

        private void LblLangToggle_Click(object sender, EventArgs e)
        {
            Tr.CurrentLang = Tr.CurrentLang == "en" ? "es" : "en";
            File.WriteAllText(langFilePath, Tr.CurrentLang);
            UpdateUITexts();
        }

        private void UpdateUITexts()
        {
            lblLangToggle.Text = Tr.CurrentLang == "en" ? "[ Cambiar a Español ]" : "[ Switch to English ]";
            lblLangToggle.Location = new System.Drawing.Point(this.ClientSize.Width - lblLangToggle.Width - 20, 20);

            lblAbout.Text = Tr.Get("about");

            // Actualizar el texto del clic derecho del icono
            if (trayMenu != null && trayMenu.Items.Count > 0)
            {
                trayMenu.Items[0].Text = Tr.Get("exit_app");
            }

            if (!isVJoyAcquired)
            {
                txtLog.Text = Tr.Get("waiting");
            }
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            AutoConfigureVJoy();
            StartServer(); // StartServer ahora se encarga de mostrar la verificación
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
            StartServer();
        }

        private void AutoConfigureVJoy()
        {
            string vJoyConfigPath = @"C:\Program Files\vJoy\x64\vJoyConfig.exe";
            if (!File.Exists(vJoyConfigPath)) return;

            // Si ya está configurado con FFB, no lo tocamos para evitar parpadeos del driver
            if (joystick.vJoyEnabled() && joystick.IsDeviceFfb(deviceId)) return;

            try
            {
                // Un solo comando unificado es más efectivo que tres separados
                // -f (Force Feedback), -a (Ejes), -b (32 Botones)
                EjecutarComandoVJoy(vJoyConfigPath, "1 -f -a x y z rx -b 32");

                // Los drivers de kernel necesitan tiempo para refrescar el registro
                System.Threading.Thread.Sleep(3000);
            }
            catch { }
        }

        private void VerificarSoporteFFB()
        {
            // Verificamos si el dispositivo está adquirido para una respuesta real
            bool hasFFB = joystick.IsDeviceFfb(deviceId);

            string msg = hasFFB
                ? "\r\n[SISTEMA] Force Feedback: ACTIVO ✅"
                : "\r\n[SISTEMA] ALERTA: El driver no reporta FFB. (Verifica vJoyConf)";

            if (txtLog.InvokeRequired)
                txtLog.Invoke(new Action(() => txtLog.AppendText(msg)));
            else
                txtLog.AppendText(msg);
        }

        

        private void EjecutarComandoVJoy(string path, string args)
        {
            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = path,
                Arguments = args,
                Verb = "runas", // Forzar elevación de privilegios
                UseShellExecute = true,
                WindowStyle = ProcessWindowStyle.Hidden
            };

            try
            {
                using (Process proc = Process.Start(psi))
                {
                    proc?.WaitForExit();
                }
            }
            catch (System.ComponentModel.Win32Exception)
            {
                // El usuario rechazó el permiso de administrador
                Invoke(new Action(() => txtLog.AppendText("\r\n[ERROR] Se requiere permiso de administrador para activar FFB.")));
            }
        }

        private void StartServer()
        {
            if (isListening) return;

            if (!joystick.vJoyEnabled())
            {
                MessageBox.Show(Tr.Get("vjoy_err"), Tr.Get("hw_error"), MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            isListening = true;
            udpServer = new UdpClient(11000);

            Task.Run(() => ListenForUDP());
            StartBeacon();
            Task.Run(() => WatchdogTimeout());

            // UI Update
            if (txtLog.InvokeRequired)
                txtLog.Invoke(new Action(() => { txtLog.Text = Tr.Get("waiting"); }));
            else
                txtLog.Text = Tr.Get("waiting");

            // Verificación final de estado tras la configuración
            VerificarSoporteFFB();
        }

        

        private void StartBeacon()
        {
            isBroadcasting = true;
            byte[] beaconData = System.Text.Encoding.UTF8.GetBytes("VWHEEL_SERVER");

            Task.Run(async () =>
            {
                while (isBroadcasting)
                {
                    NetworkInterface[] interfaces = NetworkInterface.GetAllNetworkInterfaces();
                    foreach (NetworkInterface ni in interfaces)
                    {
                        if (ni.OperationalStatus == OperationalStatus.Up &&
                            ni.NetworkInterfaceType != NetworkInterfaceType.Loopback)
                        {
                            foreach (UnicastIPAddressInformation ip in ni.GetIPProperties().UnicastAddresses)
                            {
                                if (ip.Address.AddressFamily == AddressFamily.InterNetwork)
                                {
                                    try
                                    {
                                        IPEndPoint localEP = new IPEndPoint(ip.Address, 0);
                                        using (UdpClient beacon = new UdpClient(localEP))
                                        {
                                            beacon.EnableBroadcast = true;
                                            IPEndPoint broadcastEP = new IPEndPoint(IPAddress.Broadcast, 11001);
                                            beacon.Send(beaconData, beaconData.Length, broadcastEP);
                                        }
                                    }
                                    catch { }
                                }
                            }
                        }
                    }
                    await Task.Delay(2000);
                }
            });
        }

        private async Task WatchdogTimeout()
        {
            while (isListening)
            {
                if (isVJoyAcquired && (DateTime.Now - lastPacketTime).TotalSeconds > 2)
                {
                    joystick.RelinquishVJD(deviceId);
                    isVJoyAcquired = false;
                    lastPhoneEP = null;

                    if (txtLog.InvokeRequired)
                    {
                        txtLog.Invoke(new Action(() => txtLog.Text = Tr.Get("disconnected")));
                    }
                }
                await Task.Delay(1000);
            }
        }

        private void ListenForUDP()
        {
            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 11000);

            while (isListening)
            {
                try
                {
                    byte[] receivedData = udpServer.Receive(ref remoteEP);
                    lastPacketTime = DateTime.Now;
                    lastPhoneEP = remoteEP;

                    if (receivedData.Length == 14)
                    {
                        if (!isVJoyAcquired)
                        {
                            VjdStat status = joystick.GetVJDStatus(deviceId);
                            if (status == VjdStat.VJD_STAT_FREE || status == VjdStat.VJD_STAT_OWN)
                            {
                                if (joystick.AcquireVJD(deviceId)) // Intentar adquirir
                                {
                                    isVJoyAcquired = true;

                                    // --- ACTIVACIÓN MANUAL DE FFB ---
                                    // Esto asegura que el dispositivo virtual acepte comandos de vibración
                                    

                                    joystick.FfbRegisterGenCB(ffbCallback, IntPtr.Zero);

                                    // Informar en el log tras la conexión
                                    VerificarSoporteFFB();
                                }
                            }
                        }

                        float steeringAngle = BitConverter.ToSingle(receivedData, 0);
                        ushort throttle = BitConverter.ToUInt16(receivedData, 4);
                        ushort brake = BitConverter.ToUInt16(receivedData, 6);
                        ushort clutch = BitConverter.ToUInt16(receivedData, 8);
                        uint buttons = BitConverter.ToUInt32(receivedData, 10);
                        ProcesarEjes(receivedData);

                        if (isVJoyAcquired)
                        {
                            float clampedAngle = Math.Max(-180f, Math.Min(180f, steeringAngle));
                            long axisValue = (long)(((clampedAngle + 180) / 360) * 32767) + 1;

                            joystick.SetAxis((int)axisValue, deviceId, HID_USAGES.HID_USAGE_X);
                            joystick.SetAxis(throttle, deviceId, HID_USAGES.HID_USAGE_Y);
                            joystick.SetAxis(brake, deviceId, HID_USAGES.HID_USAGE_Z);
                            joystick.SetAxis(clutch, deviceId, HID_USAGES.HID_USAGE_RX);

                            for (int i = 0; i < 32; i++)
                            {
                                bool isPressed = (buttons & (1 << i)) != 0;
                                joystick.SetBtn(isPressed, deviceId, (uint)(i + 1));
                            }
                        }

                        UpdateTelemetryUI(steeringAngle, throttle, brake, clutch, buttons);
                    }
                }
                catch (SocketException) { }
            }
        }


        private void ProcesarEjes(byte[] data)
        {
            float steeringAngle = BitConverter.ToSingle(data, 0);
            ushort throttle = BitConverter.ToUInt16(data, 4);
            ushort brake = BitConverter.ToUInt16(data, 6);
            ushort clutch = BitConverter.ToUInt16(data, 8);
            uint buttons = BitConverter.ToUInt32(data, 10);

            if (isVJoyAcquired)
            {
                float clampedAngle = Math.Max(-180f, Math.Min(180f, steeringAngle));
                long axisValue = (long)(((clampedAngle + 180) / 360) * 32767) + 1;

                joystick.SetAxis((int)axisValue, deviceId, HID_USAGES.HID_USAGE_X);
                joystick.SetAxis(throttle, deviceId, HID_USAGES.HID_USAGE_Y);
                joystick.SetAxis(brake, deviceId, HID_USAGES.HID_USAGE_Z);
                joystick.SetAxis(clutch, deviceId, HID_USAGES.HID_USAGE_RX);

                for (int i = 0; i < 32; i++)
                {
                    bool isPressed = (buttons & (1 << i)) != 0;
                    joystick.SetBtn(isPressed, deviceId, (uint)(i + 1));
                }
            }

            UpdateTelemetryUI(steeringAngle, throttle, brake, clutch, buttons);
        }

        private void OnFFBEvent(IntPtr data, object userData)
        {
            if (lastPhoneEP != null)
            {
                try
                {
                    using (UdpClient ffbSender = new UdpClient())
                    {
                        byte[] vibData = new byte[] { 1 };
                        ffbSender.Send(vibData, 1, new IPEndPoint(lastPhoneEP.Address, 11002));
                    }
                }
                catch { }
            }
        }

        private void UpdateTelemetryUI(double angle, uint throttle, uint brake, uint clutch, uint buttons)
        {
            if (txtLog.InvokeRequired)
            {
                txtLog.Invoke(new Action<double, uint, uint, uint, uint>(UpdateTelemetryUI), angle, throttle, brake, clutch, buttons);
                return;
            }

            txtLog.Text = $"{Tr.Get("telemetry")}\r\n\r\n" +
                          $"{Tr.Get("steer")}{angle:F2}°\r\n" +
                          $"{Tr.Get("accel")}{throttle}\r\n" +
                          $"{Tr.Get("brake")}{brake}\r\n" +
                          $"{Tr.Get("clutch")}{clutch}\r\n" +
                          $"{Tr.Get("btns")}{Convert.ToString(buttons, 2).PadLeft(32, '0')}";
        }

        // --- LA MAGIA OCURRE AQUÍ ---
        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Si le dieron a la 'X', cancelamos el cierre y ocultamos la app
            if (!isRealExit)
            {
                e.Cancel = true;
                this.Hide();
                return;
            }

            // Si isRealExit es true (le dieron clic derecho -> Salir al icono), matamos todo
            isListening = false;
            isBroadcasting = false;
            udpServer?.Close();

            if (isVJoyAcquired)
            {
                joystick.RelinquishVJD(deviceId);
            }

            // Escondemos el icono del tray para que no quede un icono "fantasma" flotando en Windows
            if (trayIcon != null)
            {
                trayIcon.Visible = false;
                trayIcon.Dispose();
            }
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            // Ahora el botón visual de "Close" también solo esconde la app
            this.Close(); // Esto llama a MainForm_FormClosing y se esconde
        }

        private void lblAbout_Click(object sender, EventArgs e)
        {
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = "https://x.com/ItsAdi916",
                    UseShellExecute = true
                };
                Process.Start(psi);
            }
            catch
            {
                MessageBox.Show(Tr.Get("browser_err"), Tr.Get("link_err"), MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }
    }

    // --- MOTOR DE TRADUCCIÓN ---
    public static class Tr
    {
        public static string CurrentLang = "en";

        private static readonly Dictionary<string, Dictionary<string, string>> Strings = new Dictionary<string, Dictionary<string, string>>()
        {
            { "en", new Dictionary<string, string>() {
                { "hw_error", "Hardware Error" },
                { "vjoy_err", "The vJoy driver is not installed or is currently disabled in the system." },
                { "perm_title", "Permission Denied" },
                { "admin_req", "Administrator privileges are required to auto-configure vJoy." },
                { "waiting", "=== SERVER STARTED ===\r\n\r\nWaiting for automatic mobile connection...\r\n(Auto-start enabled)" },
                { "disconnected", "=== VWHEEL TELEMETRY ===\r\n\r\nMobile disconnected.\r\nvJoy successfully released.\r\nWaiting for reconnection..." },
                { "telemetry", "=== VWHEEL TELEMETRY ===" },
                { "steer", "Steering (X Axis): " },
                { "accel", "Throttle (Y Axis): " },
                { "brake", "Brake (Z Axis):    " },
                { "clutch", "Clutch (Rx Axis):  " },
                { "btns", "Buttons (32-bit):  " },
                { "about", "VWheel Server v1.0.0\nCreated by Adi\nFeedback & Support on X: @ItsAdi916" },
                { "link_err", "Link Error" },
                { "browser_err", "Could not open the browser. Find me on X as @ItsAdi916" },
                { "exit_app", "Exit VWheel" } // NUEVO: Texto para el menú del Tray
            }},
            { "es", new Dictionary<string, string>() {
                { "hw_error", "Error de Hardware" },
                { "vjoy_err", "El controlador vJoy no está instalado o se encuentra deshabilitado en el sistema." },
                { "perm_title", "Permisos Denegados" },
                { "admin_req", "Se requieren permisos de administrador para auto-configurar vJoy." },
                { "waiting", "=== SERVIDOR INICIADO ===\r\n\r\nEsperando conexión automática del celular...\r\n(Auto-arranque activado)" },
                { "disconnected", "=== TELEMETRÍA VWHEEL ===\r\n\r\nCelular desconectado.\r\nvJoy liberado exitosamente.\r\nEsperando reconexión..." },
                { "telemetry", "=== TELEMETRÍA VWHEEL ===" },
                { "steer", "Dirección (Eje X): " },
                { "accel", "Acelerador (Eje Y): " },
                { "brake", "Freno (Eje Z):     " },
                { "clutch", "Embrague (Eje Rx): " },
                { "btns", "Botones (32 bits): " },
                { "about", "VWheel Server v1.0.0\nCreado por Adi\nFeedback y Soporte en X: @ItsAdi916" },
                { "link_err", "Error de Enlace" },
                { "browser_err", "No se pudo abrir el navegador. Búscame en X como @ItsAdi916" },
                { "exit_app", "Salir de VWheel" } // NUEVO: Texto para el menú del Tray
            }}
        };

        public static string Get(string key)
        {
            if (Strings.ContainsKey(CurrentLang) && Strings[CurrentLang].ContainsKey(key))
                return Strings[CurrentLang][key];
            return key;
        }
    }
}