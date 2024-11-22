import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ImageController.dart';

class ImagePickScreen extends StatelessWidget {
  final ImageController controller = Get.put(ImageController());

  @override
  Widget build(BuildContext context) {
    controller.getCurrentLocation();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick or Capture Image"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() {
                return controller.pickedImage.value == null
                    ? const Text("No image selected.")
                    : Image.file(controller.pickedImage.value!);
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await controller.getCurrentLocation();
                  controller.captureImage();
                },
                child: const Text("Capture Image with Location"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await controller.getCurrentLocation();
                  controller.pickImageFromGallery();
                },
                child: const Text("Pick Image from Gallery with Location"),
              ),
              ElevatedButton(
                onPressed: controller.saveCompressedImage,
                child: const Text("Save Image with Location"),
              ),  ElevatedButton(
                onPressed: controller.getCurrentLocation,
                child: const Text("Current"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
