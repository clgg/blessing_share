import 'package:blessing_share/core/widgets/app_empty_state.dart';
import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/catalog/presentation/detail_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_image_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({required this.category, super.key});

  final BlessingCategory category;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCategory(widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    return AppScaffold(
      title: widget.category.name,
      body: Builder(
        builder: (context) {
          if (catalog.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (catalog.error case final error?) {
            return AppEmptyState(
              icon: Icons.image_not_supported_outlined,
              title: '这一组素材没有加载出来',
              message: error.message,
              actionLabel: '再试一次',
              onAction: () => catalog.loadCategory(widget.category.id),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: .78,
            ),
            itemCount: catalog.categoryItems.length,
            itemBuilder: (context, index) {
              final item = catalog.categoryItems[index];
              return BlessingImageCard(
                item: item,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DetailPage(itemId: item.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
