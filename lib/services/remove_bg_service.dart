import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class RemoveBgService {
  static const _apiKey = 'YOUR_REMOVE_BG_API_KEY';
  static const _apiUrl = 'https://api.remove.bg/v1.0/removebg';

  /// 抠图，优先用 remove.bg，失败则用本地
  static Future<String?> removeBackground(String imagePath) async {
    // 先尝试 remove.bg
    final result = await _tryRemoveBg(imagePath);
    if (result != null) return result;
    
    // 失败则用本地方案
    return await _localFallback(imagePath);
  }

  static Future<String?> _tryRemoveBg(String imagePath) async {
    if (_apiKey == 'YOUR_REMOVE_BG_API_KEY') return null; // 未配置key
    try {
      final file = File(imagePath);
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl))
        ..headers['X-Api-Key'] = _apiKey
        ..files.add(await http.MultipartFile.fromPath('image_file', file.path))
        ..fields['size'] = 'auto';

      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        return await _saveImage(bytes, 'removebg');
      }
    } catch (_) {}
    return null;
  }

  /// 本地备用：直接复制原图（实际项目可集成 rembg 或 ML Kit）
  static Future<String?> _localFallback(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      return await _saveImage(bytes, 'local');
    } catch (_) {}
    return null;
  }

  static Future<String> _saveImage(Uint8List bytes, String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(bytes);
    return path;
  }
}
