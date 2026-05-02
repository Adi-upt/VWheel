import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Controlador global para el idioma
final ValueNotifier<String> appLanguage = ValueNotifier<String>('en');

// Motor de traducciones
class Tr {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'searching': 'Searching for PC on Wi-Fi...',
      'usb_enabled': 'USB Mode Enabled',
      'target': 'Target: ',
      'selected_layout': 'Selected Layout',
      'start': 'START DRIVING',
      'edit': 'EDIT LAYOUT',
      'settings': 'Settings',
      'conn_settings': 'Connection Settings',
      'usb_mode': 'USB Mode',
      'adb_rec': 'ADB Reverse (Recommended)',
      'wifi_hint': 'If using Wi-Fi, the IP will be detected automatically when starting the PC server.',
      'cancel': 'Cancel',
      'save': 'Save',
      'language': 'Language',
      'sensor_mode': 'Steering Sensor',
      'sensor_accel': 'Accelerometer (G-Sensor)',
      'sensor_gyro': 'Gyroscope (Smooth)',
      'sensor_fusion': 'Fusion (Recommended)',
      'button': 'Button',
      'pedal': 'Pedal',
      'telemetry': 'Telemetry',
      'editing_slot': 'Editing Slot ',
      'import_json': 'Import JSON',
      'export_clip': 'Export to Clipboard',
      'saved_slot': 'Saved to Slot ',
      'copied': 'Code copied to clipboard',
      'paste_json': 'Paste JSON code here',
      'import': 'Import',
      'invalid_json': 'Invalid JSON code',
      'properties': 'Properties',
      'display_text': 'Display Text',
      'copy_size': 'Copy Size',
      'paste': 'Paste',
      'dim_copied': 'Dimensions copied',
      'width': 'Width',
      'height': 'Height',
      'pos_x': 'Pos X',
      'pos_y': 'Pos Y',
      'mapping': 'Mapping (Binding)',
      'vjoy_btn': 'vJoy Button ',
      'y_axis': 'Y Axis (Throttle)',
      'z_axis': 'Z Axis (Brake)',
      'rx_axis': 'RX Axis (Clutch)',
      'delete': 'Delete Element',
      'exit_driving': 'Exit Driving',
      'exit_msg': 'Are you sure you want to exit and stop transmitting?',
      'exit': 'Exit',
      'about': 'About VWheel',
      'version': 'Version 1.0.2',
      'created_by': 'Created by',
      'feedback': 'Feedback & Support',
      'close': 'Close',
    },
    'es': {
      'searching': 'Buscando PC en la red Wi-Fi...',
      'usb_enabled': 'Modo USB Activado',
      'target': 'Destino: ',
      'selected_layout': 'Diseño Seleccionado',
      'start': 'INICIAR CONDUCCIÓN',
      'edit': 'EDITAR INTERFAZ',
      'settings': 'Configuración',
      'conn_settings': 'Configuración de Conexión',
      'usb_mode': 'Modo USB',
      'adb_rec': 'ADB Reverse (Recomendado)',
      'wifi_hint': 'Si usas Wi-Fi, la IP se detectará automáticamente al iniciar el servidor en la PC.',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'language': 'Idioma',
      'sensor_mode': 'Sensor de Volante',
      'sensor_accel': 'Acelerómetro (Gravedad)',
      'sensor_gyro': 'Giroscopio (Suave)',
      'sensor_fusion': 'Fusión (Recomendado)',
      'button': 'Botón',
      'pedal': 'Pedal',
      'telemetry': 'Telemetría',
      'editing_slot': 'Editando Slot ',
      'import_json': 'Importar JSON',
      'export_clip': 'Exportar a Portapapeles',
      'saved_slot': 'Guardado en Slot ',
      'copied': 'Código copiado al portapapeles',
      'paste_json': 'Pega el código JSON aquí',
      'import': 'Importar',
      'invalid_json': 'Código JSON inválido',
      'properties': 'Propiedades',
      'display_text': 'Texto a mostrar',
      'copy_size': 'Copiar Tam.',
      'paste': 'Pegar',
      'dim_copied': 'Dimensiones copiadas',
      'width': 'Ancho',
      'height': 'Alto',
      'pos_x': 'Pos X',
      'pos_y': 'Pos Y',
      'mapping': 'Mapeo (Binding)',
      'vjoy_btn': 'Botón vJoy ',
      'y_axis': 'Eje Y (Acelerador)',
      'z_axis': 'Eje Z (Freno)',
      'rx_axis': 'Eje RX (Embrague)',
      'delete': 'Eliminar Elemento',
      'exit_driving': 'Salir de Conducción',
      'exit_msg': '¿Estás seguro de que deseas salir y detener la transmisión?',
      'exit': 'Salir',
      'about': 'Acerca de VWheel',
      'version': 'Versión 1.0.2',
      'created_by': 'Creado por',
      'feedback': 'Feedback y Soporte',
      'close': 'Cerrar',
    }
  };

  static String get(String key) {
    return _strings[appLanguage.value]?[key] ?? key;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  appLanguage.value = prefs.getString('vwheel_lang') ?? 'en';

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const VWheelApp());
  });
}

class VWheelApp extends StatelessWidget {
  const VWheelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
        valueListenable: appLanguage,
        builder: (context, currentLang, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'VWheel Mobile',
            theme: ThemeData.dark().copyWith(
              primaryColor: Colors.blueAccent,
              scaffoldBackgroundColor: const Color(0xFF0A0A0A),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const MainMenuScreen(),
              '/play': (context) => const PlayScreen(),
              '/editor': (context) => const EditorScreen(),
            },
          );
        }
    );
  }
}

// --- SCREEN 1: MAIN MENU ---
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String targetIp = "";
  bool isUsbMode = false;
  int activeSlot = 1;
  int sensorMode = 2; // 0: Accel, 1: Gyro, 2: Fusion
  RawDatagramSocket? discoverySocket;

  @override
  void initState() {
    super.initState();
    targetIp = Tr.get('searching');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Restaurar UI estándar en el menú principal
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _loadSettings();
    _startDiscovery();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isUsbMode = prefs.getBool('vwheel_usb') ?? false;
      activeSlot = prefs.getInt('vwheel_active_slot') ?? 1;
      sensorMode = prefs.getInt('vwheel_sensor_mode') ?? 2;
      if (isUsbMode) targetIp = "127.0.0.1";
    });
  }

  Future<void> _saveSettings(bool usb, String lang, int sensor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vwheel_usb', usb);
    await prefs.setString('vwheel_lang', lang);
    await prefs.setInt('vwheel_sensor_mode', sensor);
    appLanguage.value = lang;

    setState(() {
      isUsbMode = usb;
      sensorMode = sensor;
      if (isUsbMode) {
        targetIp = "127.0.0.1";
      } else {
        targetIp = Tr.get('searching');
      }
    });
  }

  Future<void> _changeSlot(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vwheel_active_slot', slot);
    setState(() {
      activeSlot = slot;
    });
  }

  Future<void> _startDiscovery() async {
    try {
      discoverySocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 11001, reuseAddress: true, reusePort: true);
      discoverySocket!.broadcastEnabled = true;
      discoverySocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read && !isUsbMode) {
          Datagram? dg = discoverySocket!.receive();
          if (dg != null) {
            String msg = utf8.decode(dg.data);
            if (msg == "VWHEEL_SERVER") {
              String discoveredIp = dg.address.address;
              if (targetIp != discoveredIp) {
                setState(() => targetIp = discoveredIp);
              }
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Radar error: $e");
    }
  }

  @override
  void dispose() {
    discoverySocket?.close();
    super.dispose();
  }

  void _showSettingsDialog() {
    bool tempUsb = isUsbMode;
    String tempLang = appLanguage.value;
    int tempSensor = sensorMode;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(Tr.get('conn_settings')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: Tr.get('language')),
                    initialValue: tempLang,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text("English")),
                      DropdownMenuItem(value: 'es', child: Text("Español")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => tempLang = val);
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: Tr.get('sensor_mode')),
                    initialValue: tempSensor,
                    items: [
                      DropdownMenuItem(value: 0, child: Text(Tr.get('sensor_accel'))),
                      DropdownMenuItem(value: 1, child: Text(Tr.get('sensor_gyro'))),
                      DropdownMenuItem(value: 2, child: Text(Tr.get('sensor_fusion'))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => tempSensor = val);
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  SwitchListTile(
                    title: Text(Tr.get('usb_mode')),
                    subtitle: Text(Tr.get('adb_rec')),
                    value: tempUsb,
                    onChanged: (val) {
                      setDialogState(() => tempUsb = val);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      Tr.get('wifi_hint'),
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(Tr.get('cancel'))),
                ElevatedButton(
                  onPressed: () {
                    _saveSettings(tempUsb, tempLang, tempSensor);
                    Navigator.pop(context);
                  },
                  child: Text(Tr.get('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Text(Tr.get('about')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("VWheel Mobile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 5),
              Text(Tr.get('version'), style: const TextStyle(color: Colors.greenAccent)),
              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              Text(Tr.get('created_by'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const Text("Adi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text(Tr.get('feedback'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 5),
              const Row(
                children: [
                  Icon(Icons.alternate_email, size: 16, color: Colors.white54),
                  SizedBox(width: 5),
                  SelectableText("X: @ItsAdi916", style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Tr.get('close')),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isReady = targetIp != Tr.get('searching');

    return Scaffold(
      appBar: AppBar(
        title: const Text('VWheel'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') _showSettingsDialog();
              if (value == 'about') _showAboutDialog();
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'settings', child: Text(Tr.get('settings'))),
              PopupMenuItem(value: 'about', child: Text(Tr.get('about'))),
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                isUsbMode ? Icons.usb : (isReady ? Icons.wifi : Icons.wifi_find),
                size: 64,
                color: isReady ? Colors.greenAccent : Colors.white54,
              ),
              const SizedBox(height: 16),
              Text(
                isUsbMode ? Tr.get('usb_enabled') : "${Tr.get('target')}$targetIp",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isReady ? Colors.greenAccent : Colors.white54,
                    fontSize: 16,
                    fontWeight: isReady ? FontWeight.bold : FontWeight.normal
                ),
              ),
              const SizedBox(height: 40),

              Text(Tr.get('selected_layout'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  int slot = index + 1;
                  bool isSelected = activeSlot == slot;
                  return GestureDetector(
                    onTap: () => _changeSlot(slot),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                          color: isSelected ? Colors.green[800] : Colors.transparent,
                          border: Border.all(color: isSelected ? Colors.greenAccent : Colors.white24),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text("S$slot", style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: isReady ? Colors.green[800] : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isReady ? Colors.greenAccent : Colors.white24, width: 2),
                  ),
                ),
                onPressed: isReady ? () => Navigator.pushNamed(context, '/play', arguments: targetIp) : null,
                child: Text(Tr.get('start'), style: TextStyle(fontSize: 18, color: isReady ? Colors.white : Colors.white24, letterSpacing: 2)),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: Colors.white54, width: 1),
                ),
                onPressed: () => Navigator.pushNamed(context, '/editor'),
                child: Text(Tr.get('edit'), style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ADVANCED DATA MODEL ---
class VWheelElement {
  String id;
  String type;
  double x, y, width, height;
  String text;
  int bindIndex;

  VWheelElement({
    required this.id, required this.type, required this.x, required this.y,
    this.width = 80, this.height = 80, this.text = "", this.bindIndex = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'x': x, 'y': y, 'width': width, 'height': height, 'text': text, 'bindIndex': bindIndex,
  };

  factory VWheelElement.fromJson(Map<String, dynamic> json) {
    return VWheelElement(
      id: json['id'], type: json['type'], x: json['x'], y: json['y'],
      width: json['width'] ?? 80, height: json['height'] ?? 80,
      text: json['text'] ?? "", bindIndex: json['bindIndex'] ?? 0,
    );
  }
}

// --- SCREEN 3: EDITOR ---
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  List<VWheelElement> uiElements = [];
  int activeSlot = 1;

  VWheelElement? selectedElement;
  double? copiedWidth;
  double? copiedHeight;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    // OCULTAR BARRA DE NOTIFICACIONES AL ENTRAR (MODO INMERSIVO)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    final prefs = await SharedPreferences.getInstance();
    activeSlot = prefs.getInt('vwheel_active_slot') ?? 1;
    final String? jsonLayout = prefs.getString('vwheel_layout_$activeSlot');
    if (jsonLayout != null) {
      try {
        setState(() {
          uiElements = (jsonDecode(jsonLayout) as List).map((i) => VWheelElement.fromJson(i)).toList();
        });
      } catch (e) {
        debugPrint("Error loading JSON");
      }
    }
  }

  Future<void> _saveLayout() async {
    String jsonLayout = jsonEncode(uiElements.map((e) => e.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vwheel_layout_$activeSlot', jsonLayout);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${Tr.get('saved_slot')}$activeSlot'), backgroundColor: Colors.green));
  }

  void _exportLayout() {
    String jsonLayout = jsonEncode(uiElements.map((e) => e.toJson()).toList());
    Clipboard.setData(ClipboardData(text: jsonLayout));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Tr.get('copied'))));
  }

  void _importLayout() {
    TextEditingController importCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Tr.get('import_json')),
          content: TextField(
            controller: importCtrl,
            maxLines: 4,
            decoration: InputDecoration(labelText: Tr.get('paste_json'), border: const OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(Tr.get('cancel'))),
            ElevatedButton(
              onPressed: () {
                try {
                  var decoded = jsonDecode(importCtrl.text);
                  setState(() {
                    uiElements = (decoded as List).map((i) => VWheelElement.fromJson(i)).toList();
                    selectedElement = null;
                  });
                  Navigator.pop(context);
                  _saveLayout();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Tr.get('invalid_json')), backgroundColor: Colors.red));
                }
              },
              child: Text(Tr.get('import')),
            ),
          ],
        );
      },
    );
  }

  void _addElement(String type) {
    setState(() {
      var newElement = VWheelElement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type, x: 200, y: 100,
        width: type == 'telemetry' ? 240 : 80,
        height: type == 'telemetry' ? 120 : (type == 'slider' ? 200 : 80),
        text: type == 'button' ? "BTN" : "",
      );
      uiElements.add(newElement);
      selectedElement = newElement;
    });
  }

  Widget _buildPropertiesPanel() {
    if (selectedElement == null) return const SizedBox.shrink();

    // LÓGICA DE POSICIONAMIENTO DINÁMICO DEL PANEL
    // Si el elemento está en la derecha, el panel va a la izquierda.
    bool panelAtRight = selectedElement!.x < MediaQuery.of(context).size.width / 2;

    return Positioned(
      left: panelAtRight ? null : 0,
      right: panelAtRight ? 0 : null,
      top: 0,
      bottom: 0,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
          border: Border(
            left: panelAtRight ? const BorderSide(color: Colors.greenAccent, width: 2) : BorderSide.none,
            right: !panelAtRight ? const BorderSide(color: Colors.greenAccent, width: 2) : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Tr.get('properties'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => setState(() => selectedElement = null)),
              ],
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (selectedElement!.type != 'telemetry')
                      TextFormField(
                        key: ValueKey('txt_${selectedElement!.id}'),
                        initialValue: selectedElement!.text,
                        decoration: InputDecoration(labelText: Tr.get('display_text')),
                        onChanged: (val) => setState(() => selectedElement!.text = val),
                      ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(horizontal: 10)),
                          icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                          label: Text(Tr.get('copy_size'), style: const TextStyle(fontSize: 12, color: Colors.white)),
                          onPressed: () {
                            copiedWidth = selectedElement!.width; copiedHeight = selectedElement!.height;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Tr.get('dim_copied')), duration: const Duration(seconds: 1)));
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: (copiedWidth != null) ? Colors.green[700] : Colors.grey[800], padding: const EdgeInsets.symmetric(horizontal: 10)),
                          icon: const Icon(Icons.paste, size: 16, color: Colors.white),
                          label: Text(Tr.get('paste'), style: const TextStyle(fontSize: 12, color: Colors.white)),
                          onPressed: (copiedWidth != null && copiedHeight != null) ? () {
                            setState(() { selectedElement!.width = copiedWidth!; selectedElement!.height = copiedHeight!; });
                          } : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildPanelSlider(Tr.get('width'), selectedElement!.width, 20, 600, (v) => selectedElement!.width = v),
                    _buildPanelSlider(Tr.get('height'), selectedElement!.height, 20, 600, (v) => selectedElement!.height = v),
                    _buildPanelSlider(Tr.get('pos_x'), selectedElement!.x, 0, 1000, (v) => selectedElement!.x = v),
                    _buildPanelSlider(Tr.get('pos_y'), selectedElement!.y, 0, 600, (v) => selectedElement!.y = v),
                    const SizedBox(height: 10),
                    if (selectedElement!.type == 'button' || selectedElement!.type == 'slider')
                      DropdownButtonFormField<int>(
                        key: ValueKey(selectedElement!.id),
                        decoration: InputDecoration(labelText: Tr.get('mapping')),
                        initialValue: selectedElement!.bindIndex,
                        items: List.generate(32, (i) => DropdownMenuItem(value: i, child: Text("${Tr.get('vjoy_btn')}${i + 1}")))
                          ..addAll([
                            DropdownMenuItem(value: 100, child: Text(Tr.get('y_axis'))),
                            DropdownMenuItem(value: 101, child: Text(Tr.get('z_axis'))),
                            DropdownMenuItem(value: 102, child: Text(Tr.get('rx_axis'))),
                          ]),
                        onChanged: (v) => setState(() => selectedElement!.bindIndex = v ?? 0),
                      ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], padding: const EdgeInsets.symmetric(vertical: 12)),
                      icon: const Icon(Icons.delete_forever, color: Colors.white),
                      label: Text(Tr.get('delete'), style: const TextStyle(color: Colors.white)),
                      onPressed: () { setState(() { uiElements.remove(selectedElement); selectedElement = null; }); },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelSlider(String label, double val, double min, double max, Function(double) onChanged) {
    return Row(
      children: [
        SizedBox(width: 55, child: Text("$label:\n${val.toInt()}", style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(value: val, min: min, max: max, activeColor: Colors.white54, inactiveColor: Colors.white12, onChanged: (v) => setState(() => onChanged(v))),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: selectedElement != null ? null : Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(heroTag: "b1", onPressed: () => _addElement('button'), icon: const Icon(Icons.crop_square), label: Text(Tr.get('button'))),
          const SizedBox(height: 8),
          FloatingActionButton.extended(heroTag: "b2", onPressed: () => _addElement('slider'), icon: const Icon(Icons.tune), label: Text(Tr.get('pedal'))),
          const SizedBox(height: 8),
          FloatingActionButton.extended(heroTag: "b3", onPressed: () => _addElement('telemetry'), icon: const Icon(Icons.speed), label: Text(Tr.get('telemetry'))),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(onTap: () => setState(() => selectedElement = null), child: Container(color: Colors.transparent)),
          ...uiElements.map((element) {
            bool isSelected = (selectedElement == element);
            return Positioned(
              left: element.x, top: element.y,
              child: GestureDetector(
                onPanUpdate: (details) { setState(() { element.x += details.delta.dx; element.y += details.delta.dy; selectedElement = element; }); },
                onTap: () => setState(() => selectedElement = element),
                child: _buildWireframeElement(element, isSelected: isSelected),
              ),
            );
          }),
          Positioned(
              left: 20, top: 20,
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () {
                    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Restaurar UI al salir
                    Navigator.pop(context);
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: Text("${Tr.get('editing_slot')}$activeSlot", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  )
                ],
              )
          ),
          Positioned(
            right: 20, top: 20,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.download, color: Colors.blueAccent, size: 30), tooltip: Tr.get('import_json'), onPressed: _importLayout),
                IconButton(icon: const Icon(Icons.upload, color: Colors.orangeAccent, size: 30), tooltip: Tr.get('export_clip'), onPressed: _exportLayout),
                const SizedBox(width: 10),
                IconButton(icon: const Icon(Icons.save, color: Colors.greenAccent, size: 30), tooltip: Tr.get('save'), onPressed: _saveLayout),
              ],
            ),
          ),
          // LLAMADA AL PANEL DINÁMICO
          _buildPropertiesPanel(),
        ],
      ),
    );
  }

  Widget _buildWireframeElement(VWheelElement el, {bool isSelected = false}) {
    if (el.type == 'telemetry') {
      return _buildTelemetryUI(el.width, el.height, isSelected: isSelected);
    }

    return Container(
      width: el.width, height: el.height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: isSelected ? Colors.greenAccent : Colors.white38, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(el.text, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.greenAccent : Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
          if (el.type == 'slider')
            Positioned(
              bottom: (el.height / 2) - 15,
              child: Container(width: 30, height: 30, decoration: BoxDecoration(color: isSelected ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.white24, shape: BoxShape.circle)),
            ),
        ],
      ),
    );
  }

  // EL EDITOR DEBE TENER LA TELEMETRÍA ESTÁTICA
  Widget _buildTelemetryUI(double width, double height, {bool isSelected = false}) {
    return Container(
      width: width, height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(color: isSelected ? Colors.greenAccent : Colors.grey.shade800, width: isSelected ? 3 : 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          SizedBox(
            height: height * 0.25,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(15, (index) {
                  Color ledColor;
                  if (index < 5) {
                    ledColor = Colors.greenAccent;
                  } else if (index < 10) {
                    ledColor = Colors.redAccent;
                  } else {
                    ledColor = Colors.blueAccent;
                  }

                  bool isLit = index < 3; // Estático para el editor

                  return Container(
                    width: (width - 40) / 15,
                    decoration: BoxDecoration(
                      color: isLit ? ledColor : ledColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isLit ? [BoxShadow(color: ledColor, blurRadius: 5, spreadRadius: 1)] : null,
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: const Text("N", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Courier')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SCREEN 2: PLAY (REAL DRIVING) ---
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  List<VWheelElement> uiElements = [];
  int activeSlot = 1;
  int sensorMode = 2;

  // VARIABLES DINÁMICAS DE TELEMETRÍA (Solo existen aquí en el PlayScreen)
  String currentGear = "N";
  int ledsLit = 0;

  RawDatagramSocket? udpSocket;
  RawDatagramSocket? ffbSocket;
  InternetAddress? pcAddress;
  final int port = 11000;

  // --- REAL-TIME ENGINE VARIABLES ---
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  final Stopwatch _networkThrottle = Stopwatch()..start();
  DateTime _lastTime = DateTime.now();

  double currentAngle = 0.0;
  double accelAngle = 0.0;
  double gyroRate = 0.0;

  int buttonsState = 0;
  int throttleVal = 0;
  int brakeVal = 0;
  int clutchVal = 0;

  // --- LAST STATE MEMORY (Deadzone & Delta check) ---
  double _lastSentAngle = 0.0;
  int _lastSentButtons = 0;
  int _lastSentThrottle = 0;
  int _lastSentBrake = 0;
  int _lastSentClutch = 0;

  Map<String, double> sliderVisualValues = {};
  Map<String, bool> buttonVisualStates = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    // OCULTAR BARRA DE NOTIFICACIONES AL CONDUCIR
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadLayoutAndSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetIp = ModalRoute.of(context)!.settings.arguments as String;
      _setupNetwork(targetIp);
    });
  }

  Future<void> _loadLayoutAndSettings() async {
    final prefs = await SharedPreferences.getInstance();
    activeSlot = prefs.getInt('vwheel_active_slot') ?? 1;
    sensorMode = prefs.getInt('vwheel_sensor_mode') ?? 2;

    final String? jsonLayout = prefs.getString('vwheel_layout_$activeSlot');
    if (jsonLayout != null) {
      setState(() {
        uiElements = (jsonDecode(jsonLayout) as List).map((i) => VWheelElement.fromJson(i)).toList();
      });
    }

    _startSensors();
  }

  Future<void> _setupNetwork(String ip) async {
    try {
      pcAddress = InternetAddress(ip);
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      ffbSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 11002, reuseAddress: true, reusePort: true);
      ffbSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = ffbSocket!.receive();
          if (dg != null && dg.data.isNotEmpty) {
            int cmd = dg.data[0];

            // CMD 1: Force Feedback (Vibración)
            if (cmd == 1) {
              HapticFeedback.heavyImpact();
            }
            // CMD 2: Telemetría [Comando, Marcha, Luces LED]
            else if (cmd == 2 && dg.data.length >= 3) {
              int gearInt = dg.data[1];
              int leds = dg.data[2];

              String gearStr = "N";
              if (gearInt == 0) {
                gearStr = "R";
              } else if (gearInt == 1) {
                gearStr = "N";
              } else {
                gearStr = (gearInt - 1).toString();
              }

              setState(() {
                currentGear = gearStr;
                ledsLit = leds;
              });
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Network error: $e");
    }
  }

  // --- SENSOR ENGINE (EVENT DRIVEN) ---
  void _startSensors() {
    _lastTime = DateTime.now();

    const sampling = Duration(milliseconds: 10);

    if (sensorMode == 0 || sensorMode == 2) {
      _accelSub = accelerometerEventStream(samplingPeriod: sampling).listen((event) {
        accelAngle = (atan2(event.y, event.x) * (180 / pi)).clamp(-180.0, 180.0);

        if (sensorMode == 0) {
          currentAngle = accelAngle;
          _attemptSend();
        }
      });
    }

    if (sensorMode == 1 || sensorMode == 2) {
      _gyroSub = gyroscopeEventStream(samplingPeriod: sampling).listen((event) {
        DateTime now = DateTime.now();
        double dt = now.difference(_lastTime).inMicroseconds / 1000000.0;
        _lastTime = now;

        gyroRate = event.z * (180 / pi);

        if (sensorMode == 1) {
          currentAngle += gyroRate * dt;
          currentAngle = currentAngle.clamp(-180.0, 180.0);
        } else if (sensorMode == 2) {
          double alpha = 0.85;
          currentAngle = alpha * (currentAngle + gyroRate * dt) + (1.0 - alpha) * accelAngle;
          currentAngle = currentAngle.clamp(-180.0, 180.0);
        }

        _attemptSend();
      });
    }
  }

  // --- THE INTELLIGENT SEND ENGINE ---
  void _attemptSend() {
    bool angleChanged = (currentAngle - _lastSentAngle).abs() > 0.15;
    bool buttonsChanged = buttonsState != _lastSentButtons;
    bool pedalsChanged = throttleVal != _lastSentThrottle ||
        brakeVal != _lastSentBrake ||
        clutchVal != _lastSentClutch;

    if (angleChanged || buttonsChanged || pedalsChanged) {
      if (_networkThrottle.elapsedMilliseconds >= 4) {
        _sendUdpPacket();

        _lastSentAngle = currentAngle;
        _lastSentButtons = buttonsState;
        _lastSentThrottle = throttleVal;
        _lastSentBrake = brakeVal;
        _lastSentClutch = clutchVal;

        _networkThrottle.reset();
      }
    }
  }

  void _sendUdpPacket() {
    if (udpSocket == null || pcAddress == null) return;
    var byteData = ByteData(14);
    byteData.setFloat32(0, currentAngle, Endian.little);
    byteData.setUint16(4, throttleVal, Endian.little);
    byteData.setUint16(6, brakeVal, Endian.little);
    byteData.setUint16(8, clutchVal, Endian.little);
    byteData.setUint32(10, buttonsState, Endian.little);
    udpSocket!.send(byteData.buffer.asUint8List(), pcAddress!, port);
  }

  void _handleButton(VWheelElement el, bool isPressed) {
    setState(() => buttonVisualStates[el.id] = isPressed);
    if (el.bindIndex < 32) {
      if (isPressed) {
        buttonsState |= (1 << el.bindIndex);
      } else {
        buttonsState &= ~(1 << el.bindIndex);
      }
      _attemptSend();
    }
  }

  void _handleSliderUpdate(VWheelElement el, Offset localPosition) {
    double percent = (1.0 - (localPosition.dy / el.height)).clamp(0.0, 1.0);
    setState(() => sliderVisualValues[el.id] = percent);

    int val = (percent * 32767).toInt();
    if (el.bindIndex == 100) { throttleVal = val; }
    if (el.bindIndex == 101) { brakeVal = val; }
    if (el.bindIndex == 102) { clutchVal = val; }
    _attemptSend();
  }

  void _handleSliderRelease(VWheelElement el) {
    setState(() => sliderVisualValues[el.id] = 0.0);
    if (el.bindIndex == 100) { throttleVal = 0; }
    if (el.bindIndex == 101) { brakeVal = 0; }
    if (el.bindIndex == 102) { clutchVal = 0; }
    _attemptSend();
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    udpSocket?.close();
    ffbSocket?.close();
    super.dispose();
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Tr.get('exit_driving')),
          content: Text(Tr.get('exit_msg')),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(Tr.get('cancel'), style: const TextStyle(color: Colors.white70))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.of(context).pop(true), child: Text(Tr.get('exit'), style: const TextStyle(color: Colors.white))),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await _showExitConfirmationDialog();
        if (shouldPop && context.mounted) {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Restaurar UI al salir
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            ...uiElements.map((element) {
              if (element.type == 'telemetry') {
                return Positioned(left: element.x, top: element.y, child: _buildTelemetryUI(element.width, element.height));
              }

              double currentSliderPercent = sliderVisualValues[element.id] ?? 0.0;
              bool isButtonPressed = buttonVisualStates[element.id] ?? false;

              return Positioned(
                left: element.x, top: element.y,
                child: GestureDetector(
                  onPanDown: (details) {
                    if (element.type == 'button') _handleButton(element, true);
                    if (element.type == 'slider') _handleSliderUpdate(element, details.localPosition);
                  },
                  onPanUpdate: (details) {
                    if (element.type == 'slider') _handleSliderUpdate(element, details.localPosition);
                  },
                  onPanEnd: (_) {
                    if (element.type == 'button') _handleButton(element, false);
                    if (element.type == 'slider') _handleSliderRelease(element);
                  },
                  onPanCancel: () {
                    if (element.type == 'button') _handleButton(element, false);
                    if (element.type == 'slider') _handleSliderRelease(element);
                  },
                  child: Container(
                    width: element.width, height: element.height,
                    decoration: BoxDecoration(
                      color: (element.type == 'button' && isButtonPressed) ? Colors.white38 : Colors.transparent,
                      border: Border.all(color: Colors.white38, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(element.text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
                        if (element.type == 'slider')
                          Positioned(
                            bottom: currentSliderPercent * (element.height - 30),
                            child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // EL PLAYSCREEN DEBE TENER LA TELEMETRÍA DINÁMICA
  Widget _buildTelemetryUI(double width, double height) {
    return Container(
      width: width, height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(color: Colors.grey.shade800, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          SizedBox(
            height: height * 0.25,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(15, (index) {
                  Color ledColor;
                  if (index < 5) {
                    ledColor = Colors.greenAccent;
                  } else if (index < 10) {
                    ledColor = Colors.redAccent;
                  } else {
                    ledColor = Colors.blueAccent;
                  }

                  // MAGIA DINÁMICA
                  bool isLit = index < ledsLit;

                  return Container(
                    width: (width - 40) / 15,
                    decoration: BoxDecoration(
                      color: isLit ? ledColor : ledColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isLit ? [BoxShadow(color: ledColor, blurRadius: 5, spreadRadius: 1)] : null,
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.contain,
                // MAGIA DINÁMICA
                child: Text(currentGear, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Courier')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}