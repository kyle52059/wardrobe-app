import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../models/user_profile.dart';
import '../models/outfit.dart';
import '../services/wardrobe_storage.dart';
import '../services/profile_storage.dart';
import '../services/outfit_storage.dart';

class TryOnPage extends StatefulWidget {
  const TryOnPage({super.key});
  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

class _TryOnPageState extends State<TryOnPage> {
  UserProfile? _profile;
  List<ClothingItem> _items = [];
  ClothingItem? _selectedTop;
  ClothingItem? _selectedBottom;
  ClothingItem? _selectedShoes;
  ClothingItem? _selectedAccessory;
  
  Offset _topOffset = Offset.zero;
  Offset _bottomOffset = Offset.zero;
  Offset _shoesOffset = Offset.zero;
  Offset _accessoryOffset = Offset.zero;
  double _topScale = 1.0;
  double _bottomScale = 1.0;
  double _shoesScale = 0.8;
  double _accessoryScale = 0.6;

  final _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await ProfileStorage.load();
    final items = await WardrobeStorage.loadItems();
    setState(() { _profile = profile; _items = items; });
  }

  List<ClothingItem> _getByCategory(List<String> cats) =>
    _items.where((e) => cats.contains(e.category)).toList();

  Future<void> _saveOutfit() async {
    if (_selectedTop == null && _selectedBottom == null && _selectedShoes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先选择衣服')));
      return;
    }
    final outfit = Outfit(
      id: const Uuid().v4(),
      topId: _selectedTop?.id,
      bottomId: _selectedBottom?.id,
      profilePhotoPath: _profile?.photoPath,
      createdAt: DateTime.now(),
    );
    await OutfitStorage.save(outfit);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('搭配已保存！')));
  }

  Future<void> _shareOutfit() async {
    try {
      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/outfit_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles([XFile(path)], text: '看看我的穿搭！');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('分享失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile?.photoPath == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('试衣间')),
        body: const Center(child: Text('请先在"形象"页上传全身照')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('试衣间'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _resetPosition, tooltip: '重置'),
        IconButton(icon: const Icon(Icons.bookmark_add), onPressed: _saveOutfit, tooltip: '保存'),
        IconButton(icon: const Icon(Icons.share), onPressed: _shareOutfit, tooltip: '分享'),
      ]),
      body: Column(children: [
        Expanded(child: RepaintBoundary(
          key: _previewKey,
          child: Container(
            color: Colors.grey[100],
            child: LayoutBuilder(builder: (ctx, constraints) {
              final h = constraints.maxHeight;
              return Stack(alignment: Alignment.center, children: [
                Image.file(File(_profile!.photoPath!), fit: BoxFit.contain),
                if (_selectedAccessory != null) _buildDraggable(
                  item: _selectedAccessory!, offset: _accessoryOffset, scale: _accessoryScale,
                  defaultTop: h * 0.02,
                  onDrag: (d) => setState(() => _accessoryOffset += d),
                  onScale: (s) => setState(() => _accessoryScale = (_accessoryScale * s).clamp(0.2, 1.5)),
                ),
                if (_selectedTop != null) _buildDraggable(
                  item: _selectedTop!, offset: _topOffset, scale: _topScale,
                  defaultTop: h * 0.15,
                  onDrag: (d) => setState(() => _topOffset += d),
                  onScale: (s) => setState(() => _topScale = (_topScale * s).clamp(0.3, 2.0)),
                ),
                if (_selectedBottom != null) _buildDraggable(
                  item: _selectedBottom!, offset: _bottomOffset, scale: _bottomScale,
                  defaultTop: h * 0.45,
                  onDrag: (d) => setState(() => _bottomOffset += d),
                  onScale: (s) => setState(() => _bottomScale = (_bottomScale * s).clamp(0.3, 2.0)),
                ),
                if (_selectedShoes != null) _buildDraggable(
                  item: _selectedShoes!, offset: _shoesOffset, scale: _shoesScale,
                  defaultTop: h * 0.78,
                  onDrag: (d) => setState(() => _shoesOffset += d),
                  onScale: (s) => setState(() => _shoesScale = (_shoesScale * s).clamp(0.2, 1.5)),
                ),
              ]);
            }),
          ),
        )),
        Container(
          height: 180,
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
          child: ListView(padding: const EdgeInsets.symmetric(vertical: 4), children: [
            _buildSelector('上衣', _getByCategory(['上衣']), _selectedTop, (v) {
              setState(() { _selectedTop = v; _topOffset = Offset.zero; _topScale = 1.0; });
            }),
            _buildSelector('下装', _getByCategory(['裤子', '裙子']), _selectedBottom, (v) {
              setState(() { _selectedBottom = v; _bottomOffset = Offset.zero; _bottomScale = 1.0; });
            }),
            _buildSelector('鞋子', _getByCategory(['鞋子']), _selectedShoes, (v) {
              setState(() { _selectedShoes = v; _shoesOffset = Offset.zero; _shoesScale = 0.8; });
            }),
            _buildSelector('配饰', _getByCategory(['配饰']), _selectedAccessory, (v) {
              setState(() { _selectedAccessory = v; _accessoryOffset = Offset.zero; _accessoryScale = 0.6; });
            }),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDraggable({
    required ClothingItem item, required Offset offset, required double scale,
    required double defaultTop, required Function(Offset) onDrag, required Function(double) onScale,
  }) {
    return Positioned(
      top: defaultTop + offset.dy, left: offset.dx, right: -offset.dx,
      child: GestureDetector(
        onPanUpdate: (d) => onDrag(d.delta),
        onDoubleTap: () => onScale(1.2),
        onLongPress: () => onScale(0.8),
        child: Center(child: Image.file(File(item.maskedPath ?? item.imagePath), width: 120 * scale, fit: BoxFit.contain)),
      ),
    );
  }

  void _resetPosition() => setState(() {
    _topOffset = Offset.zero; _bottomOffset = Offset.zero; _shoesOffset = Offset.zero; _accessoryOffset = Offset.zero;
    _topScale = 1.0; _bottomScale = 1.0; _shoesScale = 0.8; _accessoryScale = 0.6;
  });

  Widget _buildSelector(String label, List<ClothingItem> items, ClothingItem? selected, Function(ClothingItem?) onSelect) {
    return SizedBox(height: 44, child: Row(children: [
      SizedBox(width: 50, child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      )),
      Expanded(child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) return _buildSelectorItem(null, selected == null, () => onSelect(null));
          return _buildSelectorItem(items[i - 1], selected?.id == items[i - 1].id, () => onSelect(items[i - 1]));
        },
      )),
    ]));
  }

  Widget _buildSelectorItem(ClothingItem? item, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36, margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? Colors.blue : Colors.grey[300]!, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(6), color: Colors.grey[100],
          image: item != null ? DecorationImage(image: FileImage(File(item.maskedPath ?? item.imagePath)), fit: BoxFit.cover) : null,
        ),
        child: item == null ? Icon(Icons.close, size: 16, color: Colors.grey[400]) : null,
      ),
    );
  }
}
