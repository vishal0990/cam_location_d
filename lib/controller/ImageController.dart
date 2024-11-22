import 'dart:io';
import 'dart:typed_data'; // Import the typed data library

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img; // for image manipulation
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageController extends GetxController {
  var pickedImage = Rx<File?>(null);
  var locationDetails = Rx<String?>(null);
  final ImagePicker _picker = ImagePicker();

  // Get current location and address
  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Get address from coordinates
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];

    locationDetails.value =
        "${place.name}, ${place.locality}, ${place.country}";
  }

  // Capture image from camera
  Future<void> captureImage() async {
    final permissionStatus = await Permission.camera.request();
    if (permissionStatus.isGranted) {
      final XFile? imageFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (imageFile != null) {
        pickedImage.value = File(imageFile.path);
      }
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    final permissionStatus = await Permission.photos.request();
    if (permissionStatus.isGranted) {
      final XFile? imageFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        pickedImage.value = File(imageFile.path);
      }
    }
  }

  // Save image with location details
  Future<void> saveImageWithLocation() async {
    if (pickedImage.value != null && locationDetails.value != null) {
      // Read image file
      File imageFile = pickedImage.value!;
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image image = img.decodeImage(imageBytes)!;

      // Add location overlay to image
      //  img.drawString(image, img.arial_24, 10, image.height - 30, locationDetails.value!, font: null);

      // Convert modified image back to bytes
      Uint8List modifiedImageBytes = Uint8List.fromList(img.encodeJpg(image));

      // Save the new image
      final directory = await getApplicationDocumentsDirectory();
      final savePath =
          '${directory.path}/image_with_location_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File savedImage = File(savePath);
      await savedImage.writeAsBytes(modifiedImageBytes);

      // Update UI with saved image
      pickedImage.value = savedImage;
      print('Image saved at: $savePath');
    }
  }


  Future<void> saveCompressedImage() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      String savePath;

      // Fetch current location details
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String locationDetails =
          "Lat: ${position.latitude}, Lng: ${position.longitude}";

      // Determine the save path based on the platform
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('External storage directory not available.');
        }

        final folderPath = '${directory.path}/CompressedImages';
        final folder = Directory(folderPath);
        if (!await folder.exists()) {
          await folder.create(recursive: true);
        }

        savePath =
        '$folderPath/compressed_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        savePath =
        '${directory.path}/compressed_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }

      // Pick an image using the camera
      XFile? pickedFile =
      await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        Get.snackbar(
          'Error',
          'No image captured',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      File imageFile = File(pickedFile.path);

      // Read the image file
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image image = img.decodeImage(imageBytes)!;

      // Overlay location details on the image
      img.drawString(
        image,
        img.arial14.toString(), // Font size
        10, // X position
        image.height - 30, // Adjust position for address
        address,
        color: img.getColor(0, 255, 0), font: null, // Green color
      );


      // Convert the modified image back to bytes
      Uint8List modifiedImageBytes = Uint8List.fromList(img.encodeJpg(image));

      // Save the modified image to the determined path
      File savedImage = File(savePath);
      await savedImage.writeAsBytes(modifiedImageBytes);

      // Display success message
      Get.snackbar(
        'Success',
        'Image saved successfully at $savePath',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('Image saved at: $savePath');
    } catch (e) {
      // Handle any errors that occur
      Get.snackbar(
        'Error',
        'Failed to save image: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Failed to save image: $e');
    }
  }


}
