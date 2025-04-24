import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image/image.dart' as img;

class GenerateQrCode extends StatefulWidget {
  const GenerateQrCode({super.key});

  @override
  State<GenerateQrCode> createState() => _GenerateQrCodeState();
}

class _GenerateQrCodeState extends State<GenerateQrCode> {
  TextEditingController urlController = TextEditingController();
  GlobalKey globalKey = GlobalKey();

  Future<void> _saveQrCode() async {
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      Directory? dir = await getExternalStorageDirectory();

      String newPath = "";
      List<String> paths = dir!.path.split("/");
      for (int i = 1; i < paths.length; i++) {
        if (paths[i] == "Android") break;
        newPath += "/${paths[i]}";
      }
      newPath += "/Pictures/QRApp"; // Or use /Download/QRApp

      Directory saveDir = Directory(newPath);
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      try {
        final qrValidationResult = QrValidator.validate(
          data: urlController.text,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.Q,
        );
        if (qrValidationResult.status == QrValidationStatus.valid) {
          final qrCode = qrValidationResult.qrCode!;
          final painter = QrPainter.withQr(
            qr: qrCode,
            color: const Color(0xFF000000),
            emptyColor: const Color(0xFFFFFFFF),
            gapless: true,
            embeddedImageStyle: null,
            embeddedImage: null,
          );

          final image = await painter.toImage(300); // size of image
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

          final pngBytes = byteData!.buffer.asUint8List();

          final result = await ImageGallerySaver.saveImage(
              Uint8List.fromList(pngBytes),
              quality: 100,
              name: "qr_${DateTime.now().millisecondsSinceEpoch}"
          );

          if (result['isSuccess']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Saved to Gallery!")),
            );
          }

        }
      } catch (e) {
        print('Error saving QR code: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generate QR Code")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (urlController.text.isNotEmpty)
                QrImageView(
                  data: urlController.text,
                  size: 200,
                ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: "Enter Your Data",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    labelText: "Enter Your Data",
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text("Generate QR Code"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: urlController.text.isNotEmpty ? _saveQrCode : null,
                child: Text("Save QR Code"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
