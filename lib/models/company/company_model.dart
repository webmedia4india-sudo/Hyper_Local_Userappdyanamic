class CompanyModel {
  final int companyId;
  final int employeeId;
  final String businessName;
  final String? legalName;
  final String? displayName;
  final String? industry;
  final String? establishmentYear;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? companyLogo;
  final String? companyTagline;
  final String? companyDescription;
  final String? officialWebsite;
  final String? addressLine1;
  final int activeJobsCount;

  CompanyModel({
    required this.companyId,
    required this.employeeId,
    required this.businessName,
    this.legalName,
    this.displayName,
    this.industry,
    this.establishmentYear,
    this.fullName,
    this.email,
    this.phone,
    this.companyLogo,
    this.companyTagline,
    this.companyDescription,
    this.officialWebsite,
    this.addressLine1,
    this.activeJobsCount = 0,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final cId = json['company_id'] ?? json['id'] ?? 0;
    final eId = json['employee_id'] ?? json['employer_id'] ?? 0;
    final bName = json['business_name'] ??
        json['company_name'] ??
        json['display_name'] ??
        json['legal_name'] ??
        json['name'] ??
        '';

    return CompanyModel(
      companyId: cId is int ? cId : int.tryParse(cId.toString()) ?? 0,
      employeeId: eId is int ? eId : int.tryParse(eId.toString()) ?? 0,
      businessName: bName.toString().trim().isNotEmpty
          ? bName.toString().trim()
          : 'Company',
      legalName: json['legal_name']?.toString(),
      displayName: json['display_name']?.toString(),
      industry: (json['industry'] ?? json['industry_domain'])?.toString(),
      establishmentYear: json['establishment_year']?.toString(),
      fullName: (json['full_name'] ?? json['employee_name'])?.toString(),
      email: (json['email'] ?? json['employee_email'])?.toString(),
      phone: (json['phone'] ?? json['employee_phone'])?.toString(),
      companyLogo: json['company_logo']?.toString(),
      companyTagline: json['company_tagline']?.toString(),
      companyDescription: json['company_description']?.toString(),
      officialWebsite: json['official_website']?.toString(),
      addressLine1: json['address_line_1']?.toString(),
      activeJobsCount: json['active_jobs_count'] is int
          ? json['active_jobs_count'] as int
          : int.tryParse(json['active_jobs_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'employee_id': employeeId,
      'business_name': businessName,
      'legal_name': legalName,
      'display_name': displayName,
      'industry': industry,
      'establishment_year': establishmentYear,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'company_logo': companyLogo,
      'company_tagline': companyTagline,
      'company_description': companyDescription,
      'official_website': officialWebsite,
      'address_line_1': addressLine1,
      'active_jobs_count': activeJobsCount,
    };
  }
}
