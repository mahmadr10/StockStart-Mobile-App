// ============================================================
// FILE: lib/widgets/stock_card.dart
// PURPOSE: Reusable widget — shows ONE stock as a card.
//          Used in both Home and Watchlist screens.
// ============================================================

import 'package:flutter/material.dart';
import 'package:stockstart/models/stock.dart';
import 'package:stockstart/utils/app_theme.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;

  const StockCard({super.key, required this.stock, this.onTap});

  // Returns color based on risk level
  Color get riskColor {
    switch (stock.riskLevel) {
      case 'Low':    return AppColors.green;
      case 'Medium': return AppColors.amber;
      case 'High':   return AppColors.red;
      default:       return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.change >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Green dot
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: riskColor,
                shape: BoxShape.circle,
              ),
            ),

            // Name + status (left side, expands to fill space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        stock.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Ticker badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.greyBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stock.ticker,
                          style: const TextStyle(fontSize: 10, color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        stock.status,
                        style: const TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                      const SizedBox(width: 8),
                      // Risk badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stock.riskLevel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price + change (right side)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${stock.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.w500,
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
