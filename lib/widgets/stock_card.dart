// lib/widgets/stock_card.dart
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../utils/app_theme.dart';

// ─── StockCard ────────────────────────────────────────────────────────────────
class StockCard extends StatelessWidget {
  final Stock        stock;
  final VoidCallback? onTap;
  final bool          showRisk;

  const StockCard({super.key, required this.stock, this.onTap, this.showRisk = true});

  @override
  Widget build(BuildContext context) {
    final isUp        = stock.change >= 0;
    final changeColor = AppTheme.changeColor(stock.change);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Ticker avatar
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: changeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: changeColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  stock.ticker.length > 4
                      ? stock.ticker.substring(0, 3)
                      : stock.ticker,
                  style: TextStyle(
                    color: changeColor,
                    fontSize: stock.ticker.length > 3 ? 9 : 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + status + risk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stock.status,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showRisk) ...[
                    const SizedBox(height: 5),
                    RiskBadge(riskLevel: stock.riskLevel, small: true),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Price + change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${stock.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isUp ? '+' : ''}${stock.change.toStringAsFixed(2)}%',
                    style: TextStyle(
                        color: changeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── RiskBadge ────────────────────────────────────────────────────────────────
class RiskBadge extends StatelessWidget {
  final String riskLevel;
  final bool   small;
  const RiskBadge({super.key, required this.riskLevel, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskColor(riskLevel);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 10, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$riskLevel Risk',
        style: TextStyle(
            color: color,
            fontSize: small ? 10 : 12,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── MetricTile ───────────────────────────────────────────────────────────────
class MetricTile extends StatelessWidget {
  final String  label;
  final String  value;
  final String? delta;
  final bool    deltaPositive;
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          if (delta != null) ...[
            const SizedBox(height: 2),
            Text(delta!,
                style: TextStyle(
                    color: deltaPositive
                        ? AppTheme.primary
                        : AppTheme.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

// ─── SectionHeader ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String   title;
  final String?  action;
  final VoidCallback? onAction;
  const SectionHeader(
      {super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

// ─── DailyTipCard ─────────────────────────────────────────────────────────────
class DailyTipCard extends StatelessWidget {
  final String title;
  final String body;
  final String category;
  const DailyTipCard(
      {super.key,
        required this.title,
        required this.body,
        required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.15),
            AppTheme.info.withOpacity(0.08)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Tip · $category',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 3),
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(body,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ShimmerCard ──────────────────────────────────────────────────────────────
class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key});
  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      height: 78,
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(_anim.value),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
    ),
  );
}