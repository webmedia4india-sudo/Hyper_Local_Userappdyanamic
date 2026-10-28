import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_local/utils/app_colors.dart';
import 'package:hyper_local/utils/session_manager.dart';
import 'package:hyper_local/models/job/candidate_invitation_model.dart';
import 'package:hyper_local/services/candidate_invitation_service.dart';

class InviteCandidatedPage extends StatefulWidget {
  const InviteCandidatedPage({super.key});

  @override
  State<InviteCandidatedPage> createState() => _InviteCandidatedPageState();
}

class _InviteCandidatedPageState extends State<InviteCandidatedPage> {
  final List<String> _filters = ['All', 'New', 'Accepted', 'Declined'];
  String _selectedFilter = 'All';

  List<CandidateInvitationModel> _invitations = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentCandidateId = 0;
  final Set<int> _respondingIds = {};

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userDetails = await SessionManager.getUserDetails();
      final candidateId = (userDetails['id'] is int)
          ? userDetails['id'] as int
          : int.tryParse(userDetails['id']?.toString() ?? '0') ?? 0;

      if (candidateId == 0) {
        if (mounted) {
          setState(() {
            _invitations = [];
            _isLoading = false;
            _errorMessage = "Please log in to view your invitations.";
          });
        }
        return;
      }

      _currentCandidateId = candidateId;
      final data =
          await CandidateInvitationService().getCandidateInvitations(candidateId);

      if (mounted) {
        setState(() {
          _invitations = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _respondToInvite(
      CandidateInvitationModel invite, String status) async {
    if (_respondingIds.contains(invite.id) || _currentCandidateId == 0) return;

    setState(() {
      _respondingIds.add(invite.id);
    });

    try {
      final success = await CandidateInvitationService().respondToInvitation(
        invitationId: invite.id,
        candidateId: _currentCandidateId,
        status: status,
      );

      if (success && mounted) {
        final idx = _invitations.indexWhere((i) => i.id == invite.id);
        if (idx != -1) {
          final updated = CandidateInvitationModel(
            id: invite.id,
            employerId: invite.employerId,
            candidateId: invite.candidateId,
            jobPostId: invite.jobPostId,
            message: invite.message,
            interviewDate: invite.interviewDate,
            interviewTime: invite.interviewTime,
            interviewDurationMinutes: invite.interviewDurationMinutes,
            interviewMode: invite.interviewMode,
            interviewType: invite.interviewType,
            interviewLink: invite.interviewLink,
            interviewLocation: invite.interviewLocation,
            interviewInstructions: invite.interviewInstructions,
            invitationStatus: status,
            interviewStatus: invite.interviewStatus,
            sentAt: invite.sentAt,
            respondedAt: DateTime.now().toIso8601String(),
            companyName: invite.companyName,
            companyLogo: invite.companyLogo,
            jobTitle: invite.jobTitle,
            jobCategory: invite.jobCategory,
            jobRole: invite.jobRole,
            department: invite.department,
            employmentType: invite.employmentType,
            minSalary: invite.minSalary,
            maxSalary: invite.maxSalary,
            location: invite.location,
            locality: invite.locality,
            fullAddress: invite.fullAddress,
          );
          setState(() {
            _invitations[idx] = updated;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'accepted'
                  ? 'Invitation accepted successfully!'
                  : 'Invitation declined.',
            ),
            backgroundColor:
                status == 'accepted' ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _respondingIds.remove(invite.id);
        });
      }
    }
  }

  List<CandidateInvitationModel> get _filteredInvites {
    if (_selectedFilter == 'All') return _invitations;
    if (_selectedFilter == 'New') {
      return _invitations.where((i) => i.isNew).toList();
    }
    if (_selectedFilter == 'Accepted') {
      return _invitations.where((i) => i.isAccepted).toList();
    }
    if (_selectedFilter == 'Declined') {
      return _invitations.where((i) => i.isDeclined).toList();
    }
    return _invitations;
  }

  int get _newCount => _invitations.where((i) => i.isNew).length;

  @override
  Widget build(BuildContext context) {
    final invites = _filteredInvites;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        toolbarHeight: 44,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.buttonText),
        ),
        title: const Text(
          "My Invitation",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          _buildFilterChips(),
          Expanded(
            child: _buildBody(invites),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<CandidateInvitationModel> invites) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchInvitations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (invites.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchInvitations,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: _buildEmptyState(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchInvitations,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: invites.length,
        itemBuilder: (context, index) =>
            _buildInviteCard(invites[index], index),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mail_outline_rounded,
                color: AppColors.primaryDeep, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _newCount > 0
                      ? 'You have $_newCount new invitations'
                      : 'No new invitations',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Companies are interested in your profile',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInviteCard(CandidateInvitationModel invite, int index) {
    final accent = AppColors.accents[index % AppColors.accents.length];
    final accentSoft =
        AppColors.accentsSoft[index % AppColors.accentsSoft.length];
    final isNew = invite.isNew;
    final isResponding = _respondingIds.contains(invite.id);

    final companyInitial =
        invite.companyName.isNotEmpty ? invite.companyName[0].toUpperCase() : 'C';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNew ? AppColors.primaryLight : AppColors.divider,
          width: isNew ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + title + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  companyInitial,
                  style: TextStyle(
                    color: accent == AppColors.lime
                        ? AppColors.primaryDeep
                        : accent,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.jobTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invite.companyName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(invite.invitationStatus),
            ],
          ),

          const SizedBox(height: 14),

          // Info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(Icons.location_on_outlined, invite.displayLocation),
              if (invite.minSalary != null || invite.maxSalary != null)
                _infoChip(Icons.currency_rupee_rounded, invite.displaySalary),
              _infoChip(Icons.work_outline_rounded,
                  invite.employmentType ?? 'Full Time'),
              if (invite.interviewMode != null && invite.interviewMode!.isNotEmpty)
                _infoChip(
                  invite.interviewMode == 'online'
                      ? Icons.videocam_rounded
                      : Icons.business_rounded,
                  invite.interviewMode == 'online'
                      ? 'Online Interview'
                      : 'Offline Interview',
                ),
              if (invite.interviewDate != null && invite.interviewDate!.isNotEmpty)
                _infoChip(
                  Icons.calendar_today_rounded,
                  invite.formattedInterviewDateTime,
                ),
              if (invite.interviewDurationMinutes != null)
                _infoChip(
                  Icons.timer_outlined,
                  '${invite.interviewDurationMinutes} Mins',
                ),
              if (invite.interviewType != null && invite.interviewType!.isNotEmpty)
                _infoChip(
                  Icons.category_outlined,
                  invite.interviewType!.toUpperCase(),
                ),
            ],
          ),

          if (invite.message != null && invite.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${invite.message}"',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],

          // Actionable Online Meeting Link
          if (invite.interviewMode == 'online' &&
              invite.interviewLink != null &&
              invite.interviewLink!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: invite.interviewLink!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meeting link copied to clipboard!'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Meeting Link: ${invite.interviewLink}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.copy_rounded,
                        size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],

          // Offline Interview Location
          if (invite.interviewMode == 'offline' &&
              invite.interviewLocation != null &&
              invite.interviewLocation!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Interview Location: ${invite.interviewLocation}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Instructions
          if (invite.interviewInstructions != null &&
              invite.interviewInstructions!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Instructions: ${invite.interviewInstructions}',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                'Invited ${invite.formattedSentTime}',
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Action buttons only for new/pending invites
          if (isNew) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isResponding
                        ? null
                        : () => _respondToInvite(invite, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isResponding
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error,
                            ),
                          )
                        : const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isResponding
                        ? null
                        : () => _respondToInvite(invite, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: AppColors.buttonText,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isResponding
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status.toLowerCase()) {
      case 'accepted':
        bg = AppColors.mintSoft;
        fg = AppColors.success;
        label = 'Accepted';
        break;
      case 'rejected':
      case 'declined':
        bg = AppColors.coralSoft;
        fg = AppColors.error;
        label = 'Declined';
        break;
      default:
        bg = AppColors.limeSoft;
        fg = AppColors.primaryDeep;
        label = 'New';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE3FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Color(0xFFDCE3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No invitations yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete your resume to get more invites',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
