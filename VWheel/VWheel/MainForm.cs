using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Threading;
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
        private Stopwatch ffbThrottleTimer = Stopwatch.StartNew(); // Evita saturar la red con el FFB

        // Language Variables
        private Label lblLangToggle;
        private string langFilePath = "vwheel_lang.txt";

        // System Tray Variables
        private NotifyIcon trayIcon;
        private ContextMenuStrip trayMenu;
        private bool isRealExit = false;

        public MainForm()
        {
            InitializeComponent();
            this.Text = "VWheel Receiver - Server";
            joystick = new vJoy();

            // Registramos la función que escuchará el Force Feedback nativo de Windows
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

            this.FormClosing += MainForm_FormClosing;

            SetupSystemTray();
            UpdateUITexts();
        }

        private void SetupSystemTray()
        {
            trayMenu = new ContextMenuStrip();
            trayMenu.Items.Add(Tr.Get("exit_app"), null, OnTrayExitClick);

            trayIcon = new NotifyIcon();
            trayIcon.Text = "VWheel Server";
            trayIcon.Icon = this.Icon;
            trayIcon.ContextMenuStrip = trayMenu;
            trayIcon.Visible = true;

            trayIcon.DoubleClick += TrayIcon_DoubleClick;
        }

        private void OnTrayExitClick(object sender, EventArgs e)
        {
            isRealExit = true;
            Application.Exit();
        }

        private void TrayIcon_DoubleClick(object sender, EventArgs e)
        {
            this.Show();
            this.WindowState = FormWindowState.Normal;
            this.BringToFront();
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
            StartServer();
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
            StartServer();
        }

        private void AutoConfigureVJoy()
        {
            if (joystick.vJoyEnabled() && joystick.IsDeviceFfb(deviceId) && joystick.GetVJDButtonNumber(deviceId) >= 32) return;

            string vJoyConfGuiPath = @"C:\Program Files\vJoy\x64\vJoyConf.exe";

            if (File.Exists(vJoyConfGuiPath))
            {
                MessageBox.Show(Tr.Get("setup_req_msg"), Tr.Get("setup_req_title"), MessageBoxButtons.OK, MessageBoxIcon.Information);

                try
                {
                    ProcessStartInfo psi = new ProcessStartInfo { FileName = vJoyConfGuiPath, UseShellExecute = true };
                    Process.Start(psi);
                    Environment.Exit(0);
                }
                catch { }
            }
        }

        private void CheckFFBSupport()
        {
            bool hasFFB = joystick.IsDeviceFfb(deviceId);
            string msg = hasFFB ? "\r\n[SYSTEM] Force Feedback: ACTIVE ✅" : "\r\n[SYSTEM] ALERT: Driver does not report FFB. (Check vJoyConf)";

            if (txtLog.InvokeRequired) txtLog.Invoke(new Action(() => txtLog.AppendText(msg)));
            else txtLog.AppendText(msg);
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

            Thread listenerThread = new Thread(ListenForUDP);
            listenerThread.IsBackground = true;
            listenerThread.Start();

            StartBeacon();
            Task.Run(() => WatchdogTimeout());

            if (txtLog.InvokeRequired) txtLog.Invoke(new Action(() => { txtLog.Text = Tr.Get("waiting"); }));
            else txtLog.Text = Tr.Get("waiting");

            CheckFFBSupport();
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
                        if (ni.OperationalStatus == OperationalStatus.Up && ni.NetworkInterfaceType != NetworkInterfaceType.Loopback)
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

                    if (txtLog.InvokeRequired) txtLog.Invoke(new Action(() => txtLog.Text = Tr.Get("disconnected")));
                }
                await Task.Delay(1000);
            }
        }

        private void ListenForUDP()
        {
            Thread.CurrentThread.Priority = ThreadPriority.Highest;

            Socket socket = udpServer.Client;
            socket.ReceiveBufferSize = 2048;

            byte[] buffer = new byte[14];
            EndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            Stopwatch uiThrottleTimer = Stopwatch.StartNew();

            while (isListening)
            {
                try
                {
                    int bytesRead = socket.ReceiveFrom(buffer, ref remoteEP);

                    while (socket.Available >= 14)
                    {
                        bytesRead = socket.ReceiveFrom(buffer, ref remoteEP);
                    }

                    lastPacketTime = DateTime.Now;
                    lastPhoneEP = remoteEP as IPEndPoint;

                    if (bytesRead == 14)
                    {
                        if (!isVJoyAcquired) AcquireVJoy();

                        float steeringAngle = BitConverter.ToSingle(buffer, 0);
                        ushort throttle = BitConverter.ToUInt16(buffer, 4);
                        ushort brake = BitConverter.ToUInt16(buffer, 6);
                        ushort clutch = BitConverter.ToUInt16(buffer, 8);
                        uint buttons = BitConverter.ToUInt32(buffer, 10);

                        ProcessAxes(steeringAngle, throttle, brake, clutch, buttons);

                        if (uiThrottleTimer.ElapsedMilliseconds > 50)
                        {
                            UpdateTelemetryUI(steeringAngle, throttle, brake, clutch, buttons);
                            uiThrottleTimer.Restart();
                        }
                    }
                }
                catch (SocketException) { }
            }
        }

        private void AcquireVJoy()
        {
            VjdStat status = joystick.GetVJDStatus(deviceId);
            if (status == VjdStat.VJD_STAT_FREE || status == VjdStat.VJD_STAT_OWN)
            {
                if (joystick.AcquireVJD(deviceId))
                {
                    isVJoyAcquired = true;
                    // Registramos el callback para que Windows nos avise de impactos físicos
                    joystick.FfbRegisterGenCB(ffbCallback, IntPtr.Zero);
                    CheckFFBSupport();
                }
            }
        }

        private void ProcessAxes(float steeringAngle, ushort throttle, ushort brake, ushort clutch, uint buttons)
        {
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
                    bool isPressed = (buttons & (1U << i)) != 0;
                    joystick.SetBtn(isPressed, deviceId, (uint)(i + 1));
                }
            }
        }

        // --- MOTOR DE FORCE FEEDBACK UNIVERSAL AVANZADO (v1.0.6) ---
        private void OnFFBEvent(IntPtr data, object userData)
        {
            if (lastPhoneEP == null || udpServer == null) return;

            // Limitamos a 60Hz para no saturar la red (máx ~60Hz de vibración)
            if (ffbThrottleTimer.ElapsedMilliseconds < 15) return;
            ffbThrottleTimer.Restart();

            try
            {
                FFBPType type = new FFBPType();
                if (joystick.Ffb_h_Type(data, ref type) == 0) // 0 significa Éxito
                {
                    float force = 0; // Guardará la fuerza combinada del impacto
                    byte ffbIntensity = 0; // Valor final para el celular (0-255)

                    // 1. EXTRAER MAGNITUD DE EFECTOS CONSTANTES (Choques duros, muros, baches)
                    if (type == FFBPType.PT_CONSTREP || type == FFBPType.PT_EFFREP)
                    {
                        vJoy.FFB_EFF_CONSTANT effect = new vJoy.FFB_EFF_CONSTANT();
                        if (joystick.Ffb_h_Eff_Constant(data, ref effect) == 0)
                        {
                            // Extraemos la magnitud cruda (puede ser negativa o positiva, tomamos el valor absoluto)
                            force = Math.Abs(effect.Magnitude);

                            // Mapeo dinámico: La magnitud de vJoy va de 0 a 10000.
                            float normalized = (force / 10000f) * 255f;

                            // Amplificamos *2 para que los baches se sientan con violencia
                            ffbIntensity = (byte)Math.Min(255, Math.Max(0, normalized * 2f));
                        }
                        else ffbIntensity = 150; // Fallback si falla la lectura
                    }

                    // 2. EXTRAER MAGNITUD DE EFECTOS PERIÓDICOS (Pianos, texturas, vibración motor)
                    else if (type == FFBPType.PT_PRIDREP)
                    {
                        vJoy.FFB_EFF_PERIOD effect = new vJoy.FFB_EFF_PERIOD();
                        if (joystick.Ffb_h_Eff_Period(data, ref effect) == 0)
                        {
                            force = Math.Abs(effect.Magnitude);

                            // Normalización a PWM
                            float normalized = (force / 10000f) * 255f;

                            // Amplificamos *1.5 para pianos agresivos
                            ffbIntensity = (byte)Math.Min(255, Math.Max(0, normalized * 1.5f));
                        }
                        else ffbIntensity = 80; // Fallback
                    }

                    // FILTRO DE BASURA: Los juegos envían fuerzas residuales (rozamiento del aire, etc)
                    // Ignoramos intensidades menores a 15 para que no vibre constantemente "sin razón".
                    if (ffbIntensity > 15)
                    {
                        byte[] vibData = new byte[] { 1, ffbIntensity };
                        udpServer.SendAsync(vibData, 2, new IPEndPoint(lastPhoneEP.Address, 11002));
                    }
                }
            }
            catch { }
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

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!isRealExit)
            {
                e.Cancel = true;
                this.Hide();
                return;
            }

            isListening = false;
            isBroadcasting = false;
            udpServer?.Close();

            if (isVJoyAcquired) joystick.RelinquishVJD(deviceId);

            if (trayIcon != null)
            {
                trayIcon.Visible = false;
                trayIcon.Dispose();
            }
        }

        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void lblAbout_Click(object sender, EventArgs e)
        {
            try { Process.Start(new ProcessStartInfo { FileName = "https://x.com/ItsAdi916", UseShellExecute = true }); }
            catch { MessageBox.Show(Tr.Get("browser_err"), Tr.Get("link_err"), MessageBoxButtons.OK, MessageBoxIcon.Information); }
        }

        // --- TRANSLATION ENGINE ---
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
                    { "disconnected", "=== VWHEEL INPUTS ===\r\n\r\nMobile disconnected.\r\nvJoy successfully released.\r\nWaiting for reconnection..." },
                    { "telemetry", "=== VWHEEL INPUTS ===" },
                    { "steer", "Steering (X Axis): " },
                    { "accel", "Throttle (Y Axis): " },
                    { "brake", "Brake (Z Axis):    " },
                    { "clutch", "Clutch (Rx Axis):  " },
                    { "btns", "Buttons (32-bit):  " },
                    { "about", "VWheel Server v1.0.6 (Universal FFB)\nCreated by Adi\nFeedback & Support on X: @ItsAdi916" },
                    { "link_err", "Link Error" },
                    { "browser_err", "Could not open the browser. Find me on X as @ItsAdi916" },
                    { "exit_app", "Exit VWheel" },
                    { "setup_req_title", "Configuration Required" },
                    { "setup_req_msg", "VWheel requires an initial configuration to work properly.\n\n" +
                                       "The vJoy configurator will open. Please:\n\n" +
                                       "1. Set the number of buttons to 32.\n" +
                                       "2. Check the 'Enable Effects' (Force Feedback) box.\n" +
                                       "3. Click 'Apply'.\n\n" +
                                       "Once done, close the server and open it again." }
                }},
                { "es", new Dictionary<string, string>() {
                    { "hw_error", "Error de Hardware" },
                    { "vjoy_err", "El controlador vJoy no está instalado o se encuentra deshabilitado en el sistema." },
                    { "perm_title", "Permisos Denegados" },
                    { "admin_req", "Se requieren permisos de administrador para auto-configurar vJoy." },
                    { "waiting", "=== SERVIDOR INICIADO ===\r\n\r\nEsperando conexión automática del celular...\r\n(Auto-arranque activado)" },
                    { "disconnected", "=== INPUTS VWHEEL ===\r\n\r\nCelular desconectado.\r\nvJoy liberado exitosamente.\r\nEsperando reconexión..." },
                    { "telemetry", "=== INPUTS VWHEEL ===" },
                    { "steer", "Dirección (Eje X): " },
                    { "accel", "Acelerador (Eje Y): " },
                    { "brake", "Freno (Eje Z):     " },
                    { "clutch", "Embrague (Eje Rx): " },
                    { "btns", "Botones (32 bits): " },
                    { "about", "VWheel Server v1.0.6 (Universal FFB)\nCreado por Adi\nFeedback y Soporte en X: @ItsAdi916" },
                    { "link_err", "Error de Enlace" },
                    { "browser_err", "No se pudo abrir el navegador. Búscame en X como @ItsAdi916" },
                    { "exit_app", "Salir de VWheel" },
                    { "setup_req_title", "Configuración Requerida" },
                    { "setup_req_msg", "VWheel requiere una configuración inicial para funcionar correctamente.\n\n" +
                                       "Se abrirá el configurador de vJoy. Por favor:\n\n" +
                                       "1. Pon los botones en 32.\n" +
                                       "2. Marca la casilla 'Enable Effects' (Force Feedback).\n" +
                                       "3. Haz clic en 'Apply'.\n\n" +
                                       "Una vez hecho esto, cierra el servidor y vuélvelo a abrir." }
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
}