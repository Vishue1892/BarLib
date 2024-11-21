import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'result_screen.dart';

const bgColor = Color(0xfffafafa);

class QrScanner extends StatefulWidget {
  final Function(String, String)
      onCodeScanned; // Parámetro para pasar el callback

  const QrScanner(
      {super.key, required this.onCodeScanned}); // Constructor actualizado

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool isScanCompleted = false;
  MobileScannerController controller = MobileScannerController();

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: () => controller.switchCamera(),
            icon: Icon(Icons.camera_front),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "QR Scanner",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture barcodeCapture) {
          // Verificar que haya códigos detectados
          if (!isScanCompleted && barcodeCapture.barcodes.isNotEmpty) {
            String code =
                barcodeCapture.barcodes.first.rawValue ?? 'Código no detectado';
            isScanCompleted = true;

            // Pasar el código detectado al resultado
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(
                  closeScreen: closeScreen,
                  code: code,
                  onScanCompleted: (scannedCode) {
                    // Supongamos que la respuesta del QR es una mesa y piso
                    final tableInfo =
                        scannedCode.split('_'); // Ejemplo: "Mesa 1_Piso 2"
                    if (tableInfo.length >= 2) {
                      widget.onCodeScanned(
                        tableInfo[0], // Mesa
                        tableInfo[1], // Piso
                      ); // Se pasa a HomeScreen
                    } else {
                      // En caso de que el QR no tenga el formato esperado
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Formato del código QR incorrecto")),
                      );
                    }
                    Navigator.pop(context); // Regresamos a HomeScreen
                  },
                ),
              ),
            );
          } else if (barcodeCapture.barcodes.isEmpty) {
            // Si no hay códigos detectados, mostrar un mensaje
            print("No se detectó ningún código.");
          }
        },
      ),
    );
  }
}
