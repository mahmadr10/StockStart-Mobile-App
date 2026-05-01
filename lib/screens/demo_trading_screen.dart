// lib/screens/demo_trading_screen.dart
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/trade.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class DemoTradingScreen extends StatefulWidget {
  final Stock stock;
  const DemoTradingScreen({super.key, required this.stock});
  @override
  State<DemoTradingScreen> createState() => _DemoTradingScreenState();
}

class _DemoTradingScreenState extends State<DemoTradingScreen> {
  double         _balance   = 10000;
  Map<String,int> _holdings = {};
  List<Trade>    _trades    = [];
  int            _qty       = 1;
  bool           _loading   = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final results = await Future.wait([
      DatabaseService.getVirtualBalance(),
      DatabaseService.getHoldings(),
      DatabaseService.getAllTrades(),
    ]);
    if (!mounted) return;
    setState(() {
      _balance  = results[0] as double;
      _holdings = results[1] as Map<String,int>;
      _trades   = results[2] as List<Trade>;
      _loading  = false;
    });
  }

  int    get _held         => _holdings[widget.stock.ticker] ?? 0;
  double get _txValue      => _qty * widget.stock.price;
  double get _unrealizedPL {
    if (_held == 0) return 0;
    final buys = _trades.where((t) =>
    t.ticker == widget.stock.ticker && t.type == 'BUY').toList();
    if (buys.isEmpty) return 0;
    final avgBuy = buys.map((t) => t.priceAtTrade).reduce((a, b) => a + b) /
        buys.length;
    return (widget.stock.price - avgBuy) * _held;
  }

  Future<void> _buy() async {
    if (_txValue > _balance) {
      _snack('Insufficient virtual balance!', AppTheme.danger); return;
    }
    await DatabaseService.setVirtualBalance(_balance - _txValue);
    await DatabaseService.recordTrade(Trade(
      ticker: widget.stock.ticker, stockName: widget.stock.name,
      type: 'BUY', quantity: _qty,
      priceAtTrade: widget.stock.price, timestamp: DateTime.now(),
    ));
    await _load();
    _snack('Bought $_qty ${widget.stock.ticker} @ \$${widget.stock.price.toStringAsFixed(2)}',
        AppTheme.primary);
  }

  Future<void> _sell() async {
    if (_held < _qty) {
      _snack('You only own $_held share(s) of ${widget.stock.ticker}!',
          AppTheme.danger);
      return;
    }
    await DatabaseService.setVirtualBalance(_balance + _txValue);
    await DatabaseService.recordTrade(Trade(
      ticker: widget.stock.ticker, stockName: widget.stock.name,
      type: 'SELL', quantity: _qty,
      priceAtTrade: widget.stock.price, timestamp: DateTime.now(),
    ));
    await _load();
    _snack('Sold $_qty ${widget.stock.ticker} @ \$${widget.stock.price.toStringAsFixed(2)}',
        AppTheme.danger);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final plColor = _unrealizedPL >= 0 ? AppTheme.primary : AppTheme.danger;

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
          ? const Center(
          child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Balance card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.18),
                    AppTheme.surface
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Virtual Balance',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('\$${_balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 38,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    'Unrealized P&L: ${_unrealizedPL >= 0 ? '+' : ''}\$${_unrealizedPL.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: plColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Stock info ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.stock.ticker,
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18)),
                      Text(widget.stock.name,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          '\$${widget.stock.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18)),
                      Text('You own: $_held share(s)',
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Quantity ──
            const Text('Quantity',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                _qtyBtn(Icons.remove_rounded,
                        () { if (_qty > 1) setState(() => _qty--); }),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary),
                    ),
                    child: Text(_qty.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 14),
                _qtyBtn(Icons.add_rounded,
                        () => setState(() => _qty++)),
              ],
            ),

            const SizedBox(height: 14),

            // Transaction value
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transaction Value',
                      style: TextStyle(
                          color: AppTheme.textSecondary)),
                  Text('\$${_txValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Buy / Sell buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _buy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(0, 52),
                    ),
                    child: const Text('BUY',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sell,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                    ),
                    child: const Text('SELL',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Trade history
            if (_trades.isNotEmpty) ...[
              const Text('Trade History',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const SizedBox(height: 10),
              ..._trades.take(20).map(_tradeRow),
            ],
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Icon(icon, color: AppTheme.primary),
    ),
  );

  Widget _tradeRow(Trade t) {
    final isBuy = t.type == 'BUY';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isBuy
                  ? AppTheme.primary.withOpacity(0.15)
                  : AppTheme.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(t.type,
                style: TextStyle(
                    color: isBuy ? AppTheme.primary : AppTheme.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t.quantity}x ${t.ticker}',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text(
                    '@\$${t.priceAtTrade.toStringAsFixed(2)}  ·  ${_fmt(t.timestamp)}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isBuy ? '-' : '+'}\$${t.totalValue.toStringAsFixed(2)}',
            style: TextStyle(
                color: isBuy ? AppTheme.danger : AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}