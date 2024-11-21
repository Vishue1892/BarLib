import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String code;
  final VoidCallback closeScreen;
  final Function(String) onScanCompleted;

  const ResultScreen({
    super.key,
    required this.closeScreen,
    required this.code,
    required this.onScanCompleted, // Asegúrate de recibir este parámetro
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resultado del Escaneo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Código Escaneado: $code",
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                // Llama a la función onScanCompleted cuando se complete el escaneo
                onScanCompleted(code);
                closeScreen(); // Cierra la pantalla de escaneo
              },
              child: Text("Confirmar Código"),
            ),
          ],
        ),
      ),
    );
  }
}
