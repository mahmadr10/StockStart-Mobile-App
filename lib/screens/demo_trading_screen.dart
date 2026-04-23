// ============================================================
// FILE: lib/screens/demo_trading_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/trade.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_card.dart';

class DemoTradingScreen extends StatefulWidget {
  final Stock stock;
  const DemoTradingScreen({super.key, required this.stock});
  @override
  State<DemoTradingScreen> createState() => _DemoTradingScreenState();
}

class _DemoTradingScreenState extends State<DemoTradingScreen> {
  double _balance = 10000;
  Map<String, int> _holdings = {};
  List<Trade> _trades = [];
  int _quantity = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final [balance, holdings, trades] = await Future.wait([
      DatabaseService.getVirtualBalance(),
      DatabaseService.getHoldings(),
      DatabaseService.getAllTrades(),
    ]);
    setState(() {
      _balance = balance as double;
      _holdings = holdings as Map<String, int>;
      _trades = trades as List<Trade>;
      _loading = false;
    });
  }

  int get _currentHolding => _holdings[widget.stock.ticker] ?? 0;
  double get _potentialCost => _quantity * widget.stock.price;
  double get _potentialProfit {
    if (_currentHolding == 0) return 0;
    // Simplified: uses average entry cost from last buy
    final buys = _trades.where((t) => t.ticker == widget.stock.ticker && t.type == 'BUY').toList();
    if (buys.isEmpty) return 0;
    final avgBuy = buys.map((t) => t.priceAtTrade).reduce((a, b) => a + b) / buys.length;
    return (widget.stock.price - avgBuy) * _currentHolding;
  }

  Future<void> _buy() async {
    if (_potentialCost > _balance) {
      _showError('Insufficient virtual balance!');
      return;
    }
    final newBalance = _balance - _potentialCost;
    await DatabaseService.setVirtualBalance(newBalance);
    await DatabaseService.recordTrade(Trade(
      ticker: widget.stock.ticker,
      stockName: widget.stock.name,
      type: 'BUY',
      quantity: _quantity,
      priceAtTrade: widget.stock.price,
      timestamp: DateTime.now(),
    ));
    await _load();
    _showSuccess('Bought $_quantity ${widget.stock.ticker} @ \$${widget.stock.price.toStringAsFixed(2)}');
  }

  Future<void> _sell() async {
    if (_currentHolding < _quantity) {
      _showError('You only own $_currentHolding shares of ${widget.stock.ticker}!');
      return;
    }
    final newBalance = _balance + _potentialCost;
    await DatabaseService.setVirtualBalance(newBalance);
    await DatabaseService.recordTrade(Trade(
      ticker: widget.stock.ticker,
      stockName: widget.stock.name,
      type: 'SELL',
      quantity: _quantity,
      priceAtTrade: widget.stock.price,
      timestamp: DateTime.now(),
    ));
    await _load();
    _showSuccess('Sold $_quantity ${widget.stock.ticker} @ \$${widget.stock.price.toStringAsFixed(2)}');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.danger));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.primary));
  }

  @override
  Widget build(BuildContext context) {
    final profitColor = _potentialProfit >= 0 ? AppTheme.primary : AppTheme.danger;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Demo Trading'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary.withOpacity(0.15), AppTheme.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Virtual Balance', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '\$${_balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'P&L: ${_potentialProfit >= 0 ? '+' : ''}\$${_potentialProfit.toStringAsFixed(2)}',
                    style: TextStyle(color: profitColor, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stock info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.stock.ticker, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 18)),
                      Text(widget.stock.name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${widget.stock.price.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
                      Text('You own: $_currentHolding shares', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quantity selector
            const Text('Quantity', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                _QtyButton(icon: Icons.remove_rounded, onTap: () { if (_quantity > 1) setState(() => _quantity--); }),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primary),
                    ),
                    child: Text(
                      _quantity.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _QtyButton(icon: Icons.add_rounded, onTap: () => setState(() => _quantity++)),
              ],
            ),

            const SizedBox(height: 16),

            // Cost summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transaction Value', style: TextStyle(color: AppTheme.textSecondary)),
                  Text('\$${_potentialCost.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Buy / Sell
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _buy,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.black),
                    child: const Text('BUY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sell,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white),
                    child: const Text('SELL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Trade history
            if (_trades.isNotEmpty) ...[
              const Text('Trade History', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              ...(_trades.take(10).map((t) => _TradeRow(trade: t))),
            ],
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.primary),
      ),
    );
  }
}

class _TradeRow extends StatelessWidget {
  final Trade trade;
  const _TradeRow({required this.trade});

  @override
  Widget build(BuildContext context) {
    final isBuy = trade.type == 'BUY';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isBuy ? AppTheme.primary.withOpacity(0.15) : AppTheme.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(trade.type, style: TextStyle(color: isBuy ? AppTheme.primary : AppTheme.danger, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${trade.quantity}x ${trade.ticker}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
              Text('@\$${trade.priceAtTrade.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
          const Spacer(),
          Text(
            '${isBuy ? '-' : '+'}\$${trade.totalValue.toStringAsFixed(2)}',
            style: TextStyle(color: isBuy ? AppTheme.danger : AppTheme.primary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}