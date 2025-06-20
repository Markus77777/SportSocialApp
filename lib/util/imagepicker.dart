import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerr {
  Future<File?> uploadImage(String inputSource) async {
    final picker = ImagePicker();
    final XFile? pickerImage = await picker.pickImage(
      source:
          inputSource == 'cammera' ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickerImage!= null) {
      File videoFile = File(pickerImage.path);
      return videoFile; // 返回選擇的視頻文件
    }
    
    return null; 
  }
}
