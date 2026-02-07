import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/profile_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile _profile = UserProfile();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ProfileStorage.load();
    if (p != null) {
      setState(() => _profile = p);
      _heightCtrl.text = p.height?.toString() ?? '';
      _weightCtrl.text = p.weight?.toString() ?? '';
    }
  }

  Future<void> _pickPhoto() async {
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
    if (picked != null) {
      setState(() => _profile = _profile.copyWith(photoPath: picked.path));
      await _save();
    }
  }

  Future<void> _save() async {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    final updated = _profile.copyWith(height: h, weight: w);
    await ProfileStorage.save(updated);
    setState(() => _profile = updated);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的形象')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        GestureDetector(
          onTap: _pickPhoto,
          child: Container(
            width: 200, height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(12),
              image: _profile.photoPath != null
                ? DecorationImage(image: FileImage(File(_profile.photoPath!)), fit: BoxFit.cover)
                : null,
            ),
            child: _profile.photoPath == null
              ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.person_add, size: 48, color: Colors.grey),
                  SizedBox(height: 8), Text('点击上传全身照', style: TextStyle(color: Colors.grey)),
                ])
              : null,
          ),
        ),
        const SizedBox(height: 24),
        TextField(controller: _heightCtrl, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '身高 (cm)', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextField(controller: _weightCtrl, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '体重 (kg)', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _profile.bodyType,
          decoration: const InputDecoration(labelText: '体型', border: OutlineInputBorder()),
          items: ['偏瘦', '标准', '偏胖'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _profile = _profile.copyWith(bodyType: v)),
        ),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('保存'))),
      ])),
    );
  }
}
