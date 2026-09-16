import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '隐私与权限',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.storage_outlined, size: 30),
            title: Text('本地数据'),
            subtitle: Text('收藏、历史和演示登录状态保存在设备本地。'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.photo_library_outlined, size: 30),
            title: Text('相册权限'),
            subtitle: Text('当前版本不会申请相册权限，也不会真正保存图片。'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.chat_bubble_outline_rounded, size: 30),
            title: Text('微信接入'),
            subtitle: Text('当前版本不会唤起微信，后续接入时会单独说明用途。'),
          ),
        ],
      ),
    );
  }
}
