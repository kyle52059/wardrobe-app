import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../services/wardrobe_storage.dart';
import '../services/remove_bg_service.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});
  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> with SingleTickerProviderStateMixin {
  List<ClothingItem> _items = [];
  bool _loading = false;
  late TabController _tabCtrl;
  
  final _categories = ['全部', '上衣', '裤子', '裙子', '鞋子', '配饰'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _categories.length, vsync: this);
    _loadItems();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await WardrobeStorage.loadItems();
    setState(() => _items = items);
  }

  List<ClothingItem> _filteredItems(String category) {
    if (category == '全部') return _items;
    return _items.where((e) => e.category == category).toList();
  }

  Future<void> _addClothing() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.camera), title: const Text('拍照'),
          onTap: () => Navigator.pop(context, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo), title: const Text('相册'),
          onTap: () => Navigator.pop(context, ImageSource.gallery)),
      ]),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    final category = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(title: const Text('选择分类'),
        children: _categories.skip(1).map((c) => SimpleDialogOption(
          child: Text(c), onPressed: () => Navigator.pop(context, c),
        )).toList()),
    );
    if (category == null) return;

    setState(() => _loading = true);
    final maskedPath = await RemoveBgService.removeBackground(picked.path);
    
    final item = ClothingItem(
      id: const Uuid().v4(),
      imagePath: picked.path,
      maskedPath: maskedPath,
      category: category,
      createdAt: DateTime.now(),
    );
    await WardrobeStorage.addItem(item);
    await _loadItems();
    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(maskedPath != null ? '添加成功' : '添加成功（抠图失败）'),
      ));
    }
  }

  Future<void> _deleteItem(ClothingItem item) async {
    await WardrobeStorage.deleteItem(item.id);
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的衣柜'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: _loading
        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(), SizedBox(height: 16), Text('AI抠图中...')]))
        : TabBarView(
            controller: _tabCtrl,
            children: _categories.map((c) => _buildGrid(_filteredItems(c))).toList(),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loading ? null : _addClothing,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGrid(List<ClothingItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('暂无衣服'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildItem(items[i]),
    );
  }

  Widget _buildItem(ClothingItem item) {
    final path = item.maskedPath ?? item.imagePath;
    return GestureDetector(
      onLongPress: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('删除'),
          content: const Text('确定删除这件衣服？'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            TextButton(onPressed: () { Navigator.pop(context); _deleteItem(item); },
              child: const Text('删除', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        ),
        Positioned(bottom: 4, left: 4, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
          child: Text(item.category, style: const TextStyle(color: Colors.white, fontSize: 10)),
        )),
      ]),
    );
  }
}
