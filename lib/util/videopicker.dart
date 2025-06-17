import 'dart:io';
import 'package:image_picker/image_picker.dart';

class VideoPickerService {
  Future<File?> uploadVideo(String inputSource) async {
    final picker = ImagePicker(); // 使用 ImagePicker 來選擇視頻
    final XFile? pickedVideo = await picker.pickVideo(
      source: inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedVideo != null) {
      File videoFile = File(pickedVideo.path);
      return videoFile; // 返回選擇的視頻文件
    }
    
    return null; 
  }
}