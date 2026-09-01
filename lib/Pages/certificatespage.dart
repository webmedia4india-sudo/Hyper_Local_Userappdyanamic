import 'package:flutter/material.dart';
import 'package:hyper_local/utils/app_colors.dart';

// ---------------- Certificate Model ----------------
class CertificateModel {
  String title;
  String issuer;
  String issueDate;
  String credentialId;

  CertificateModel({
    required this.title,
    required this.issuer,
    required this.issueDate,
    this.credentialId = "",
  });
}

// ---------------- Certificates Page ----------------
class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  final List<CertificateModel> _certificates = [
    CertificateModel(
      title: "Flutter Development Bootcamp",
      issuer: "Udemy",
      issueDate: "Mar 2023",
      credentialId: "UC-8823A1",
    ),
    CertificateModel(
      title: "Google Associate Android Developer",
      issuer: "Google",
      issueDate: "Nov 2022",
      credentialId: "GAAD-2291",
    ),
  ];

  void _openCertificateForm({CertificateModel? certificate, int? index}) {
    final titleController = TextEditingController(text: certificate?.title ?? "");
    final issuerController = TextEditingController(text: certificate?.issuer ?? "");
    final dateController = TextEditingController(text: certificate?.issueDate ?? "");
    final credentialController =
        TextEditingController(text: certificate?.credentialId ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  certificate == null ? "Add Certificate" : "Edit Certificate",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(controller: titleController, label: "Certificate Title"),
                const SizedBox(height: 14),
                _buildTextField(controller: issuerController, label: "Issuing Organization"),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: dateController,
                  label: "Issue Date (e.g. Mar 2023)",
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: credentialController,
                  label: "Credential ID (optional)",
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty ||
                          issuerController.text.trim().isEmpty) {
                        return;
                      }
                      setState(() {
                        if (certificate == null) {
                          _certificates.add(
                            CertificateModel(
                              title: titleController.text.trim(),
                              issuer: issuerController.text.trim(),
                              issueDate: dateController.text.trim(),
                              credentialId: credentialController.text.trim(),
                            ),
                          );
                        } else {
                          _certificates[index!].title = titleController.text.trim();
                          _certificates[index].issuer = issuerController.text.trim();
                          _certificates[index].issueDate = dateController.text.trim();
                          _certificates[index].credentialId =
                              credentialController.text.trim();
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      certificate == null ? "Save Certificate" : "Update Certificate",
                      style: const TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        filled: true,
        fillColor: AppColors.scaffoldBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.background,
        title: const Text(
          "Delete Certificate",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          "Are you sure you want to delete this certificate?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _certificates.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
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
          "Certificates",
          style: TextStyle(
            color: AppColors.buttonText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openCertificateForm(),
        child: const Icon(Icons.add, color: AppColors.buttonText),
      ),
      body: _certificates.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
              itemCount: _certificates.length,
              itemBuilder: (context, index) {
                final cert = _certificates[index];
                return _buildCertificateCard(cert, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_outlined,
                size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Certificates Added",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Tap + to add your certifications",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(CertificateModel cert, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.workspace_premium, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  cert.issuer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Issued ${cert.issueDate}",
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                if (cert.credentialId.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.otpBoxBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.otpBoxBorder),
                    ),
                    child: Text(
                      "ID: ${cert.credentialId}",
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textHint, size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (value) {
              if (value == "edit") {
                _openCertificateForm(certificate: cert, index: index);
              } else if (value == "delete") {
                _confirmDelete(index);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "edit",
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: "delete",
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text("Delete"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}