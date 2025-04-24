import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  String qrResult = "Scanned result will appear here ";
  Future<void>scanQR()async{
    try{
final qrCode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.QR);
if(!mounted)return;
setState(() {
  this.qrResult = qrCode.toString();
});

    }on PlatformException{
      qrResult = "fail to read QR code ";
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR")),
      body: Center(

          child: Column(
            children: [
              SizedBox(height: 10,),
              Text( "$qrResult", style: TextStyle(color: Colors.black),),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: scanQR, child: Text("Scan Code")),



            ],
          ),
      ),
    );
  }
}
