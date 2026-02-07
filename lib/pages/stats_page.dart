import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/wardrobe_storage.dart';
import '../services/outfit_storage.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<ClothingItem> _items = [];
  List<Outfit> _outfits = [];
  Map<String, int> _usageCount = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await WardrobeStorage.loadItems();
    final outfits = await OutfitStorage.loadAll();
    
    // 统计每件衣服使用次数
    final usage = <String, int>{};
    for (var o in outfits) {
      if (o.topId != null) usage[o.topId!] = (usage[o.topId!] ?? 0) + 1;
      if (o.bottomId != null) usage[o.bottomId!] = (usage[o.bottomId!] ?? 0) + 1;
    }
    
    setState(() { _items = items; _outfits = outfits; _usageCount = usage; });
  }

  @override
  Widget build(BuildContext context) {
    final categoryCount = <String, int>{};
    for (var item in _items) {
      categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
    }

    // 最常穿
    final mostUsed = _items.where((i) => (_usageCount[i.id] ?? 0) > 0).toList()
      ..sort((a, b) => (_usageCount[b.id] ?? 0).compareTo(_usageCount[a.id] ?? 0));
    
    // 闲置（从未使用且超过30天）
    final idle = _items.where((i) => 
      (_usageCount[i.id] ?? 0) == 0 && 
      DateTime.now().difference(i.createdAt).inDays > 30
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('衣柜统计')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // 总览卡片
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('衣柜总览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildStat('总数', '${_items.length}件'),
              _buildStat('搭配', '${_outfits.length}套'),
              _buildStat('闲置', '${idle.length}件'),
            ]),
          ]),
        )),
        const SizedBox(height: 16),

        // 分类统计
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('分类统计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...categoryCount.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SizedBox(width: 60, child: Text(e.key)),
                Expanded(child: LinearProgressIndicator(
                  value: _items.isEmpty ? 0 : e.value / _items.length,
                  backgroundColor: Colors.grey[200],
                )),
                const SizedBox(width: 8),
                Text('${e.value}件'),
              ]),
            )),
          ]),
        )),
        const SizedBox(height: 16),

        // 最常穿
        if (mostUsed.isNotEmpty) ...[
          const Text('👕 最常穿', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(height: 90, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mostUsed.take(10).length,
            itemBuilder: (_, i) => _buildItemCard(mostUsed[i], '${_usageCount[mostUsed[i].id]}次'),
          )),
          const SizedBox(height: 16),
        ],

        // 闲置提醒
        if (idle.isNotEmpty) ...[
          const Text('💤 闲置超30天', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(height: 90, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: idle.length,
            itemBuilder: (_, i) {
              final days = DateTime.now().difference(idle[i].createdAt).inDays;
              return _buildItemCard(idle[i], '$days天未穿');
            },
          )),
        ],
      ]),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
      Text(label, style: TextStyle(color: Colors.grey[600])),
    ]);
  }

  Widget _buildItemCard(ClothingItem item, String subtitle) {
    return Container(
      width: 70, margin: const EdgeInsets.only(right: 8),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(item.maskedPath ?? item.imagePath), width: 60, height: 60, fit: BoxFit.cover),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
