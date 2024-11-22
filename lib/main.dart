import 'package:cam_location_d/utils.dart';
import 'package:cam_location_d/view/ImagePickScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cameraPermission();
  await storagePermission();
  await locationPermission();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Image Capture with Location',
      home: ImagePickScreen(),
    );
  }
}
