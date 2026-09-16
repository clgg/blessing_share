import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/app_empty_state.dart';
import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:blessing_share/core/widgets/app_toast.dart';
import 'package:blessing_share/core/widgets/primary_action_button.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/favorites/favorites_provider.dart';
import 'package:blessing_share/features/profile/activity_provider.dart';
import 'package:blessing_share/features/profile/domain/activity_record.dart';
import 'package:blessing_share/features/wechat/wechat_gateway.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({required this.itemId, super.key});

  final String itemId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final Future<BlessingItem> _item =
      context.read<CatalogProvider>().itemById(widget.itemId);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '祝福详情',
      body: FutureBuilder<BlessingItem>(
        future: _item,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const AppEmptyState(
              icon: Icons.broken_image_outlined,
              title: '素材暂时无法打开',
              message: '请返回后重新选择一张祝福图片',
            );
          }
          return _DetailContent(item: snapshot.requireData);
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.item});

  final BlessingItem item;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesProvider, bool>(
      (provider) => provider.contains(item.id),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(item.imageAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(item.title,
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              SizedBox.square(
                dimension: 56,
                child: IconButton.filledTonal(
                  tooltip: isFavorite ? '取消收藏' : '收藏',
                  onPressed: () => _toggleFavorite(context),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.caption, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          PrimaryActionButton(
            label: '发给微信好友',
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: () => _share(context, ShareTarget.friend),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _share(context, ShareTarget.timeline),
            icon: const Icon(Icons.people_outline_rounded),
            label: const Text('分享到朋友圈'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _save(context),
            icon: const Icon(Icons.download_outlined),
            label: const Text('保存到相册'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56)),
          ),
          const SizedBox(height: 16),
          Text(
            '当前为框架演示：操作只生成本地演示记录，不会调用微信或写入系统相册。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final favorites = context.read<FavoritesProvider>();
    final wasFavorite = favorites.contains(item.id);
    await favorites.toggle(item);
    if (!context.mounted) return;
    AppToast.show(
      context,
      type: AppToastType.success,
      message: wasFavorite ? '已取消收藏' : '已收藏到本地',
    );
  }

  Future<void> _share(BuildContext context, ShareTarget target) async {
    final gateway = context.read<WechatGateway>();
    final result = target == ShareTarget.friend
        ? await gateway.shareToFriend(item)
        : await gateway.shareToTimeline(item);
    await context.read<ActivityProvider>().recordShare(item.id, target);
    if (!context.mounted) return;
    AppToast.show(
      context,
      type: AppToastType.info,
      message: result.message,
    );
  }

  Future<void> _save(BuildContext context) async {
    await context.read<ActivityProvider>().recordSave(item.id);
    if (!context.mounted) return;
    AppToast.show(
      context,
      type: AppToastType.info,
      message: '已生成保存演示记录，暂未写入系统相册',
    );
  }
}
