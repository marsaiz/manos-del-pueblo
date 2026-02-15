import 'image_picker_bridge.dart';
import 'package:image_picker/image_picker.dart';

Future<PickedImageData?> pickImageDataImpl() async {
  final picker = ImagePicker();
  final file = await picker.pickImage(source: ImageSource.gallery);
  if (file == null) {
    return null;
  }

  final bytes = await file.readAsBytes();
  return PickedImageData(
    bytes: bytes,
    mimeType: file.mimeType,
  );
}
