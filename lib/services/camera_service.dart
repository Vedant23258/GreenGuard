import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    final status = await Permission.camera.status;
    if (status.isDenied || status.isRestricted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        return null;
      }
    }

    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 85,
    );

    return file?.path;
  }
}


