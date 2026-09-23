import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../domain/entities/concession_item.dart';

class ConcessionSelectorWidget extends StatefulWidget {
  final Map<String, ConcessionOrderItem> selectedConcessions;
  final Function(ConcessionItem, int) onQuantityChanged;

  const ConcessionSelectorWidget({
    super.key,
    required this.selectedConcessions,
    required this.onQuantityChanged,
  });

  @override
  State<ConcessionSelectorWidget> createState() =>
      _ConcessionSelectorWidgetState();
}

class _ConcessionSelectorWidgetState extends State<ConcessionSelectorWidget> {
  ConcessionCategory _selectedCategory = ConcessionCategory.combos;
  List<ConcessionItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConcessions();
  }

  Future<void> _loadConcessions() async {
    final list = await ServiceLocator.concessionDataSource.getConcessions();
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items
        .where((i) => i.category == _selectedCategory)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryTab(
                ConcessionCategory.combos,
                'Combos & Meals',
                Icons.fastfood_rounded,
              ),
              const SizedBox(width: 8),
              _buildCategoryTab(
                ConcessionCategory.popcorn,
                'Popcorn',
                Icons.grain_rounded,
              ),
              const SizedBox(width: 8),
              _buildCategoryTab(
                ConcessionCategory.drinks,
                'Drinks',
                Icons.local_drink_rounded,
              ),
              const SizedBox(width: 8),
              _buildCategoryTab(
                ConcessionCategory.snacks,
                'Warm Snacks',
                Icons.lunch_dining_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Items List
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              final orderItem = widget.selectedConcessions[item.id];
              final quantity = orderItem?.quantity ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Item Image with Optional Popular Badge
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              item.imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              webHtmlElementStrategy:
                                  WebHtmlElementStrategy.fallback,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 72,
                                    height: 72,
                                    color: AppColors.surfaceElevated,
                                    child: const Icon(
                                      Icons.fastfood_rounded,
                                      color: Colors.white38,
                                    ),
                                  ),
                            ),
                          ),
                          if (item.isPopular)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Item Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.description,
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.formatCurrency(item.price),
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.accentGold,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Stepper +/-
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.glassBorderSubtle,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (quantity > 0) ...[
                              _buildStepBtn(
                                icon: Icons.remove_rounded,
                                onTap: () => widget.onQuantityChanged(item, -1),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  '$quantity',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                            _buildStepBtn(
                              icon: Icons.add_rounded,
                              isPrimary: true,
                              onTap: () => widget.onQuantityChanged(item, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildStepBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : AppColors.surfaceLighter,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryTab(
    ConcessionCategory category,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.surfaceLighter.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.glassBorderSubtle,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
