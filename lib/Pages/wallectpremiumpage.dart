import 'package:flutter/material.dart';
import 'package:hyper_local/Pages/primiumplanspage.dart';
import 'package:hyper_local/Pages/airesumebuilderpage.dart';
import '../utils/app_colors.dart';

class WalletPremiumPage extends StatefulWidget {
  final double initialBalance;
  final List<Map<String, dynamic>>? initialTransactions;

  const WalletPremiumPage({
    super.key,
    this.initialBalance = 2450,
    this.initialTransactions,
  });

  @override
  State<WalletPremiumPage> createState() => _WalletPremiumPageState();
}

class _WalletPremiumPageState extends State<WalletPremiumPage> with SingleTickerProviderStateMixin {
  late double _balance;
  late List<Map<String, dynamic>> _transactions;
  late TabController _tabController;

  // Wallet breakdowns
  final double _referralBalance = 300.0;
  final double _cashbackBalance = 150.0;
  double _promotionalBalance = 2000.0;

  // Expiry info
  final String _promoExpiryDate = "31 Dec 2026";
  final String _referralExpiryDate = "15 Oct 2026";

  // Transaction filter: 'All', 'Credit', 'Debit'
  String _activeFilter = 'All';

  // Subscription state
  final bool _isPremiumActive = true;
  final String _activePlanName = "HyperLocal Gold Annual";
  final double _planPrice = 1999.0;
  final String _billingPeriod = "Yearly";
  final String _renewalDate = "12 May 2027";
  bool _autoRenewStatus = true;

  @override
  void initState() {
    super.initState();
    _balance = widget.initialBalance;
    _tabController = TabController(length: 2, vsync: this);
    _transactions = widget.initialTransactions != null
        ? List.from(widget.initialTransactions!)
        : [
            {
              "icon": Icons.card_giftcard_rounded,
              "iconBg": const Color(0xFFE8F5E9),
              "iconColor": AppColors.success,
              "title": "Cashback Received",
              "date": "12 May 2026",
              "amount": 150,
              "isCredit": true,
              "type": "Cashback",
            },
            {
              "icon": Icons.person_add_rounded,
              "iconBg": const Color(0xFFE3F2FD),
              "iconColor": Colors.blue,
              "title": "Referral Reward Earned",
              "date": "10 May 2026",
              "amount": 300,
              "isCredit": true,
              "type": "Referral",
            },
            {
              "icon": Icons.workspace_premium_rounded,
              "iconBg": const Color(0xFFFFEBEE),
              "iconColor": AppColors.error,
              "title": "Premium Membership Renewal",
              "date": "08 May 2026",
              "amount": 1999,
              "isCredit": false,
              "type": "Debit",
            },
            {
              "icon": Icons.stars_rounded,
              "iconBg": const Color(0xFFFFF8E1),
              "iconColor": Colors.amber,
              "title": "Promotional Welcome Credits",
              "date": "01 May 2026",
              "amount": 2000,
              "isCredit": true,
              "type": "Promotional",
            },
          ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addMoneyDialog() {
    double inputAmount = 500.0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add Promotional Credits", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter mock funds amount to add to your promotional credits:"),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: "500",
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount (₹)",
                  prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) inputAmount = parsed;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  _balance += inputAmount;
                  _promotionalBalance += inputAmount;
                  _transactions.insert(0, {
                    "icon": Icons.add_circle_outline_rounded,
                    "iconBg": const Color(0xFFE8F5E9),
                    "iconColor": AppColors.success,
                    "title": "Wallet Added Credits",
                    "date": "Today",
                    "amount": inputAmount.toInt(),
                    "isCredit": true,
                    "type": "Promotional",
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Successfully added ₹${inputAmount.toInt()} promotional credits.")),
                );
              },
              child: const Text("Add Credits"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "Wallet & Premium",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "My Wallet", icon: Icon(Icons.account_balance_wallet_rounded, size: 20)),
            Tab(text: "Premium", icon: Icon(Icons.workspace_premium_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── TAB 1: WALLET ──
          _buildWalletTab(),

          // ── TAB 2: PREMIUM SUBSCRIPTION ──
          _buildPremiumTab(),
        ],
      ),
    );
  }

  // ── WALLET TAB CONTENT ──
  Widget _buildWalletTab() {
    // Filter logic
    final filteredTxs = _transactions.where((tx) {
      if (_activeFilter == 'Credit') return tx["isCredit"] as bool;
      if (_activeFilter == 'Debit') return !(tx["isCredit"] as bool);
      return true;
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Promotional, Referral & Cashbacks Balance",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                "₹${_balance.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.buttonText),
              ),
              const SizedBox(height: 2),
              const Text("Total Wallet Balance", style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PremiumPlansPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("View Plans", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: _addMoneyDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Add Money",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Balance Breakdown Types (Referral rewards, Cashback, Promotional credits)
        const Text("Wallet Balance Breakdown", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _breakdownCard(
                title: "Promotional Credits",
                amount: _promotionalBalance,
                expiryText: "Expiry: $_promoExpiryDate",
                cardColor: Colors.amber[50]!,
                tintColor: Colors.amber[800]!,
                icon: Icons.stars_rounded,
              ),
              const SizedBox(width: 10),
              _breakdownCard(
                title: "Referral Rewards",
                amount: _referralBalance,
                expiryText: "Expiry: $_referralExpiryDate",
                cardColor: Colors.blue[50]!,
                tintColor: Colors.blue[800]!,
                icon: Icons.person_add_rounded,
              ),
              const SizedBox(width: 10),
              _breakdownCard(
                title: "Cashback Balance",
                amount: _cashbackBalance,
                expiryText: "Non-expiring credits",
                cardColor: Colors.green[50]!,
                tintColor: Colors.green[800]!,
                icon: Icons.card_giftcard_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Filter chips & Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Transaction History",
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Row(
              children: ["All", "Credit", "Debit"].map((filt) {
                final isSel = _activeFilter == filt;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = filt),
                  child: Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      filt,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Transaction list builder
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: filteredTxs.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text("No transactions recorded.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                )
              : Column(
                  children: List.generate(filteredTxs.length, (index) {
                    final tx = filteredTxs[index];
                    final isLast = index == filteredTxs.length - 1;
                    return Column(
                      children: [
                        _transactionTile(tx),
                        if (!isLast) const Divider(height: 1, indent: 60, color: AppColors.divider),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }

  // breakdown card builder
  Widget _breakdownCard({
    required String title,
    required double amount,
    required String expiryText,
    required Color cardColor,
    required Color tintColor,
    required IconData icon,
  }) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tintColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tintColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: tintColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "₹${amount.toStringAsFixed(0)}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: tintColor),
          ),
          const SizedBox(height: 4),
          Text(
            expiryText,
            style: const TextStyle(fontSize: 10, color: Colors.black54, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> tx) {
    final bool isCredit = tx["isCredit"] as bool;
    final int amount = tx["amount"] as int;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tx["iconBg"] as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              tx["icon"] as IconData,
              size: 19,
              color: tx["iconColor"] as Color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx["title"] as String,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  tx["date"] as String,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          Text(
            "${isCredit ? '+' : '-'} ₹$amount",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ── PREMIUM SUBSCRIPTION TAB CONTENT ──
  Widget _buildPremiumTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Auto-renew status & subscription info card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        _isPremiumActive ? "Premium Active" : "No Active Premium",
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (_isPremiumActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Auto-Renew On",
                        style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    )
                ],
              ),
              const Divider(height: 24),
              _subInfoRow("Subscription Plan:", _activePlanName),
              const SizedBox(height: 8),
              _subInfoRow("Plan Price / Fee:", "₹${_planPrice.toInt()}"),
              const SizedBox(height: 8),
              _subInfoRow("Billing Cycle:", _billingPeriod),
              const SizedBox(height: 8),
              _subInfoRow("Renewal Date:", _renewalDate),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Subscription Auto-Renew Status", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  Switch(
                    value: _autoRenewStatus,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _autoRenewStatus = val;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_autoRenewStatus ? "Auto-renew option enabled." : "Auto-renew option disabled.")),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Premium Advantages / Perks Title
        const Text(
          "Candidate Premium Perks & Benefits",
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),

        // Perks List
        Column(
          children: [
            _perkTile(
              icon: Icons.rocket_launch_rounded,
              title: "Priority Application",
              desc: "Get pushed to the top of recruiter application pools instantly.",
              color: Colors.deepOrange,
            ),
            _perkTile(
              icon: Icons.wb_sunny_rounded,
              title: "Profile Highlight",
              desc: "A yellow border highlight inside candidate searches.",
              color: Colors.amber,
            ),
            _perkTile(
              icon: Icons.verified_user_rounded,
              title: "Premium Badge",
              desc: "Displays premium user tag badge across recruiter views.",
              color: Colors.blue,
            ),
                      _perkTile(
              icon: Icons.psychology_rounded,
              title: "AI Resume Review",
              desc: "Automated real-time parsing report card checklist feedback.",
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIResumeBuilderPage()),
                );
              },
            ),
            _perkTile(
              icon: Icons.filter_alt_rounded,
              title: "Advanced Job Filters",
              desc: "Filter results by micro-local blocks, immediate salary range.",
              color: Colors.teal,
            ),
            _perkTile(
              icon: Icons.access_time_filled_rounded,
              title: "Early Job Access",
              desc: "Get applying privileges 24 hours ahead of standard users.",
              color: Colors.green,
            ),
            _perkTile(
              icon: Icons.contact_support_rounded,
              title: "Career Guidance Mentor",
              desc: "Dedicated personal career support counselor channels.",
              color: Colors.indigo,
            ),
            _perkTile(
              icon: Icons.interpreter_mode_rounded,
              title: "Mock Interviews Prep",
              desc: "Practice with custom interactive video mock panels.",
              color: Colors.pink,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Manage Membership button
        SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumPlansPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Manage Membership Plans", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _subInfoRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
        Text(val, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _perkTile({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(desc, style: const TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.3)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}