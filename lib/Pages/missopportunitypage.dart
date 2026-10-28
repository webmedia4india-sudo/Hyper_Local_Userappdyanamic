import 'package:flutter/material.dart';
import 'package:hyper_local/models/job/missed_opportunity_model.dart';
import 'package:hyper_local/services/missed_opportunity_service.dart';
import 'package:hyper_local/utils/session_manager.dart';
import '../utils/app_colors.dart';

/// Data for a single missed job — pass a list of these to [MissOpportunityPage].
class MissedJobInfo {
  const MissedJobInfo({
    required this.companyName,
    required this.jobTitle,
    this.companyFullName = "",
    this.salary = "",
    this.logoText = "?",
    this.logoColor = AppColors.primary,
    this.logoImageUrl,
    this.logoAssetPath,
    this.postedDate = "",
    this.missedDate = "",
    this.reason = "This opportunity is no longer available.",
  });

  final String companyName;
  final String jobTitle;
  final String companyFullName;
  final String salary;
  final String logoText;
  final Color logoColor;
  final String? logoImageUrl;
  final String? logoAssetPath;
  final String postedDate;
  final String missedDate;
  final String reason;
}

class MissOpportunityPage extends StatefulWidget {
  final List<MissedJobInfo>? missedJobs;
  final VoidCallback? onBrowseJobs;
  final void Function(MissedJobInfo job)? onJobTap;

  const MissOpportunityPage({
    super.key,
    this.missedJobs,
    this.onBrowseJobs,
    this.onJobTap,
  });

  @override
  State<MissOpportunityPage> createState() => _MissOpportunityPageState();
}

class _MissOpportunityPageState extends State<MissOpportunityPage> {
  List<MissedJobInfo> _missedJobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.missedJobs != null) {
      _missedJobs = List.from(widget.missedJobs!);
      _isLoading = false;
      _fetchMissedJobs(showLoading: false);
    } else {
      _fetchMissedJobs(showLoading: true);
    }
  }

  Future<void> _fetchMissedJobs({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final userDetails = await SessionManager.getUserDetails();
      final userId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;

      if (userId == 0) {
        if (mounted) {
          setState(() {
            _missedJobs = [];
            _isLoading = false;
            _errorMessage = "Please log in to view missed opportunities.";
          });
        }
        return;
      }

      final res = await MissedOpportunityService().getMissedOpportunitiesByUser(userId);
      if (mounted) {
        if (res['success'] == true && res['items'] is List<MissedOpportunityModel>) {
          final items = (res['items'] as List<MissedOpportunityModel>)
              .where((m) => m.isWithinRetentionPeriod)
              .toList();
          setState(() {
            _missedJobs = items.map((m) => MissedJobInfo(
              companyName: m.companyName,
              jobTitle: m.title,
              companyFullName: m.companyFullName ?? "${m.companyName} Pvt. Ltd.",
              salary: m.formattedSalary,
              logoText: m.logoLetter,
              logoColor: m.logoColor,
              postedDate: m.formattedPostedDate,
              missedDate: m.formattedClosedDate,
              reason: m.formattedReason,
            )).toList();
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _missedJobs = [];
            _isLoading = false;
            _errorMessage = res['message']?.toString();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching missed jobs page: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load missed opportunities.";
        });
      }
    }
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
          "Missed Opportunities",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMissedJobs,
        color: AppColors.primary,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchMissedJobs,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Retry", style: TextStyle(color: AppColors.buttonText)),
            ),
          ],
        ),
      );
    }

    if (_missedJobs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.accentsSoft[0]],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDeep.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No Missed Opportunities",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "You're all caught up! No missed job deadlines found.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onBrowseJobs ?? () => Navigator.pop(context),
              icon: const Icon(Icons.search_rounded, size: 20),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: const Text(
                "Browse Jobs",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: [
        // ── STATUS BANNER ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryLight, AppColors.accentsSoft[0]],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDeep.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hourglass_disabled_rounded,
                  color: AppColors.primaryDark,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You Missed These Opportunities",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${_missedJobs.length} jobs you applied late for or missed out on",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── LIST OF MISSED JOB CARDS ───────────────────────
        ..._missedJobs.map((job) => _missedJobCard(context, job)),
        const SizedBox(height: 8),

        // ── CTA: browse similar jobs ──────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onBrowseJobs ?? () => Navigator.pop(context),
            icon: const Icon(Icons.search_rounded, size: 20),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.buttonText,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: const Text(
              "Browse Similar Jobs",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ── SINGLE MISSED JOB CARD ─────────────────────────────────
  Widget _missedJobCard(BuildContext context, MissedJobInfo job) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: widget.onJobTap == null ? null : () => widget.onJobTap!(job),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _companyLogo(job),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.companyName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.jobTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          if (job.companyFullName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              job.companyFullName,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (job.salary.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mintSoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${job.salary} /month",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _dateInfo(
                        icon: Icons.campaign_rounded,
                        iconColor: AppColors.primary,
                        label: "Posted On",
                        value: job.postedDate,
                      ),
                    ),
                    Expanded(
                      child: _dateInfo(
                        icon: Icons.event_busy_rounded,
                        iconColor: AppColors.coral,
                        label: "Closed On",
                        value: job.missedDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  job.reason,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── DATE INFO CHIP (posted / closed) ──────────────────────
  Widget _dateInfo({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── COMPANY LOGO ──────────────────────────────────────────
  Widget _companyLogo(MissedJobInfo job) {
    Widget child;

    if (job.logoAssetPath != null) {
      child = Image.asset(
        job.logoAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _logoLetterFallback(job.logoText),
      );
    } else if (job.logoImageUrl != null) {
      child = Image.network(
        job.logoImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, widget, progress) {
          if (progress == null) return widget;
          return _logoLetterFallback(job.logoText);
        },
        errorBuilder: (_, _, _) => _logoLetterFallback(job.logoText),
      );
    } else {
      child = _logoLetterFallback(job.logoText);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 54,
        height: 54,
        color: job.logoColor,
        child: child,
      ),
    );
  }

  Widget _logoLetterFallback(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.buttonText,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}