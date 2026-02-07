import 'dart:io';
import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/clothing_item.dart';
import '../services/outfit_storage.dart';
import '../services/wardrobe_storage.dart';

class OutfitsPage extends StatefulWidget {
  const OutfitsPage({super.key});
  @override
  State<OutfitsPage> createState() => _OutfitsPageState();
}

class _OutfitsPageState extends State<OutfitsPage> {
  List<Outfit> _outfits = [];
  Map<String, ClothingItem> _itemsMap = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final outfits = await OutfitStorage.loadAll();
    final items = await WardrobeStorage.loadItems();
    setState(() {
      _outfits = outfits;
      _itemsMap = {for (var i in items) i.id: i};
    });
  }

  Future<void> _delete(String id) async {
    await OutfitStorage.delete(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的搭配')),
      body: _outfits.isEmpty
        ? const Center(child: Text('还没有保存的搭配\n去试衣间搭配后点击保存', textAlign: TextAlign.center))
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _outfits.length,
            itemBuilder: (_, i) => _buildOutfitCard(_outfits[i]),
          ),
    );
  }

  Widget _buildOutfitCard(Outfit outfit) {
    final top = outfit.topId != null ? _itemsMap[outfit.topId] : null;
    final bottom = outfit.bottomId != null ? _itemsMap[outfit.bottomId] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          // 缩略图
          if (outfit.profilePhotoPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(outfit.profilePhotoPath!), width: 60, height: 90, fit: BoxFit.cover),
            ),
          const SizedBox(width: 12),
          // 衣服
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('搭配 ${outfit.createdAt.month}/${outfit.createdAt.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              if (top != null) _buildThumb(top),
              if (bottom != null) _buildThumb(bottom),
              if (top == null && bottom == null) const Text('衣服已删除', style: TextStyle(color: Colors.grey)),
            ]),
          ])),
          // 删除
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('删除搭配'),
                content: const Text('确定删除这个搭配？'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                  TextButton(onPressed: () { Navigator.pop(context); _delete(outfit.id); }, child: const Text('删除')),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildThumb(ClothingItem item) {
    return Container(
      width: 40, height: 40, margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        image: DecorationImage(image: FileImage(File(item.maskedPath ?? item.imagePath)), fit: BoxFit.cover),
      ),
    );
  }
}
