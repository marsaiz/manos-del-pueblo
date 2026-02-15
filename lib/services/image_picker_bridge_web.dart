import 'image_picker_bridge.dart';
import 'package:image_picker_web/image_picker_web.dart';

Future<PickedImageData?> pickImageDataImpl() async {
  final mediaData = await ImagePickerWeb.getImageInfo();
  if (mediaData == null || mediaData.data == null) {
    return null;
  }

  return PickedImageData(
    bytes: mediaData.data!,
    mimeType: null,
  );
}
