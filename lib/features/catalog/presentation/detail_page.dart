import 'package:blessing_share/app/app_theme.dart';
import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/core/widgets/speakable.dart';
import 'package:blessing_share/core/widgets/wechat_share_icons.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/favorites/favorites_provider.dart';
import 'package:blessing_share/features/likes/like_provider.dart';
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
    final colors = context.blessingColors;
    final isLiked = context.select<LikeProvider, bool>(
      (provider) => provider.contains(item.id),
    );
    final isFavorite = context.select<FavoritesProvider, bool>(
      (provider) => provider.contains(item.id),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Single GestureDetector owns tap (zoom) + long-press (TTS) to
          // avoid nested recognizers swallowing the long-press.
          GestureDetector(
            onTap: () => ZoomableImagePage.open(
              context,
              imageAsset: item.imageAsset,
              imageUrl: item.imageUrl,
              title: item.title,
            ),
            onLongPress: () => speakForAccessibility(context, item.title),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: item.aspectRatio,
                child: BlessingMediaImage(
                  imageKey: const Key('detail-hero-image'),
                  assetPath: item.imageAsset,
                  networkUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  semanticLabel: item.title,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Speakable(
                  text: item.title,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              SizedBox.square(
                dimension: 56,
                child: Semantics(
                  button: true,
                  label: isLiked ? '取消点赞' : '点赞',
                  excludeSemantics: true,
                  child: IconButton.filledTonal(
                    tooltip: isLiked ? '取消点赞' : '点赞',
                    onPressed: () => _toggleLike(context),
                    icon: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox.square(
                dimension: 56,
                child: Semantics(
                  button: true,
                  label: isFavorite ? '取消收藏' : '收藏',
                  excludeSemantics: true,
                  child: IconButton.filledTonal(
                    tooltip: isFavorite ? '取消收藏' : '收藏',
                    onPressed: () => _toggleFavorite(context),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Speakable(
            text: item.caption,
            child: Text(
              item.caption,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryActionButton(
            label: '发给微信好友',
            iconWidget: const WechatFriendIcon(size: 24),
            onPressed: () => _share(context, ShareTarget.friend),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _share(context, ShareTarget.timeline),
              icon: const MomentsIcon(size: 24),
              label: const Text('分享到朋友圈'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _save(context),
              icon: const Icon(Icons.download_outlined),
              label: const Text('保存到相册'),
            ),
          ),
          const SizedBox(height: 16),
          Speakable(
            text: '当前为框架演示：操作只生成本地演示记录，不会调用微信或写入系统相册。',
            child: Text(
              '当前为框架演示：操作只生成本地演示记录，不会调用微信或写入系统相册。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(BuildContext context) async {
    final likes = context.read<LikeProvider>();
    final wasLiked = likes.contains(item.id);
    await likes.toggle(item);
    if (!context.mounted) return;
    AppToast.show(
      context,
      type: AppToastType.success,
      message: wasLiked ? '已取消点赞' : '已点赞',
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
    final activity = context.read<ActivityProvider>();
    final result = target == ShareTarget.friend
        ? await gateway.shareToFriend(item)
        : await gateway.shareToTimeline(item);
    await activity.recordShare(item.id, target);
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
