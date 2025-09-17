// 🎓 Bursary Models - All the data structures for our bursary system
// These models match the FastAPI backend schema perfectly!
// Generated from ZA Bursaries Scraping API (FastAPI Pydantic models)

// 🏢 Provider Model - Who's offering the bursary?
class Provider {
  final String name;
  final String? description;
  final String? website;
  final String? email;
  final String? phone;
  final String? logo;

  Provider({
    required this.name,
    this.description,
    this.website,
    this.email,
    this.phone,
    this.logo,
  });

  factory Provider.fromJson(Map<String, dynamic> json) => Provider(
    name: json['name'],
    description: json['description'],
    website: json['website'],
    email: json['email'],
    phone: json['phone'],
    logo: json['logo'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'website': website,
    'email': email,
    'phone': phone,
    'logo': logo,
  };
}

// 💰 Coverage Model - What expenses are covered?
class Coverage {
  final String type; // "full" or "partial"
  final int? amount;
  final List<String> covers;

  Coverage({required this.type, this.amount, required this.covers});

  factory Coverage.fromJson(Map<String, dynamic> json) => Coverage(
    type: json['type'],
    amount: json['amount'],
    covers: List<String>.from(json['covers'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'covers': covers,
  };
}

// 💼 Work-Back Obligation - Do you need to work for them after?
class WorkBackObligation {
  final bool required;
  final String? duration;
  final String? department;
  final List<String> additionalBenefits;

  WorkBackObligation({
    required this.required,
    this.duration,
    this.department,
    required this.additionalBenefits,
  });

  factory WorkBackObligation.fromJson(Map<String, dynamic> json) =>
      WorkBackObligation(
        required: json['required'],
        duration: json['duration'],
        department: json['department'],
        additionalBenefits: List<String>.from(json['additionalBenefits'] ?? []),
      );

  Map<String, dynamic> toJson() => {
    'required': required,
    'duration': duration,
    'department': department,
    'additionalBenefits': additionalBenefits,
  };
}

// ⏰ Deadline Model - When does it close?
class Deadline {
  final String closingDate;
  final String displayText;
  final int? daysLeft;
  final bool isUrgent;

  Deadline({
    required this.closingDate,
    required this.displayText,
    this.daysLeft,
    required this.isUrgent,
  });

  // 🔥 Quick check if this is super urgent (less than 7 days)
  bool get isCritical => daysLeft != null && daysLeft! <= 7;

  factory Deadline.fromJson(Map<String, dynamic> json) => Deadline(
    closingDate: json['closingDate'],
    displayText: json['displayText'],
    daysLeft: json['daysLeft'],
    isUrgent: json['isUrgent'],
  );

  Map<String, dynamic> toJson() => {
    'closingDate': closingDate,
    'displayText': displayText,
    'daysLeft': daysLeft,
    'isUrgent': isUrgent,
  };
}

// 📚 Academic Requirements - What grades do you need?
class AcademicRequirements {
  final String? minimumQualification;
  final List<String> studyYear;
  final int? overallAverage;
  final List<Map<String, dynamic>> specificSubjects;

  AcademicRequirements({
    this.minimumQualification,
    required this.studyYear,
    this.overallAverage,
    required this.specificSubjects,
  });

  factory AcademicRequirements.fromJson(Map<String, dynamic> json) =>
      AcademicRequirements(
        minimumQualification: json['minimumQualification'],
        studyYear: List<String>.from(json['studyYear'] ?? []),
        overallAverage: json['overallAverage'],
        specificSubjects: List<Map<String, dynamic>>.from(
          json['specificSubjects'] ?? [],
        ),
      );

  Map<String, dynamic> toJson() => {
    'minimumQualification': minimumQualification,
    'studyYear': studyYear,
    'overallAverage': overallAverage,
    'specificSubjects': specificSubjects,
  };
}

// ✅ Eligibility Model - Can you apply?
class Eligibility {
  final String? citizenship;
  final int? maxAge;
  final AcademicRequirements? academicRequirements;
  final List<String> qualifications;
  final String? institutionType;

  Eligibility({
    this.citizenship,
    this.maxAge,
    this.academicRequirements,
    required this.qualifications,
    this.institutionType,
  });

  factory Eligibility.fromJson(Map<String, dynamic> json) => Eligibility(
    citizenship: json['citizenship'],
    maxAge: json['maxAge'],
    academicRequirements: json['academicRequirements'] != null
        ? AcademicRequirements.fromJson(json['academicRequirements'])
        : null,
    qualifications: List<String>.from(json['qualifications'] ?? []),
    institutionType: json['institutionType'],
  );

  Map<String, dynamic> toJson() => {
    'citizenship': citizenship,
    'maxAge': maxAge,
    'academicRequirements': academicRequirements?.toJson(),
    'qualifications': qualifications,
    'institutionType': institutionType,
  };
}

// 📝 Application Process - How do you apply?
class ApplicationProcess {
  final String method;
  final List<String> steps;
  final String? applicationUrl;
  final String? referenceNumber;

  ApplicationProcess({
    required this.method,
    required this.steps,
    this.applicationUrl,
    this.referenceNumber,
  });

  factory ApplicationProcess.fromJson(Map<String, dynamic> json) =>
      ApplicationProcess(
        method: json['method'],
        steps: List<String>.from(json['steps'] ?? []),
        applicationUrl: json['applicationUrl'],
        referenceNumber: json['referenceNumber'],
      );

  Map<String, dynamic> toJson() => {
    'method': method,
    'steps': steps,
    'applicationUrl': applicationUrl,
    'referenceNumber': referenceNumber,
  };
}

// 🎯 Selection Process - How do they choose winners?
class SelectionProcess {
  final String? timeframe;
  final String? priorityPolicy;
  final bool noResponseMeansRejection;

  SelectionProcess({
    this.timeframe,
    this.priorityPolicy,
    required this.noResponseMeansRejection,
  });

  factory SelectionProcess.fromJson(Map<String, dynamic> json) =>
      SelectionProcess(
        timeframe: json['timeframe'],
        priorityPolicy: json['priorityPolicy'],
        noResponseMeansRejection: json['noResponseMeansRejection'],
      );

  Map<String, dynamic> toJson() => {
    'timeframe': timeframe,
    'priorityPolicy': priorityPolicy,
    'noResponseMeansRejection': noResponseMeansRejection,
  };
}

// 🕷️ Scraped Info - Metadata about when this was scraped
class ScrapedInfo {
  final String sourceUrl;
  final String lastUpdated;
  final String scrapedAt;

  ScrapedInfo({
    required this.sourceUrl,
    required this.lastUpdated,
    required this.scrapedAt,
  });

  factory ScrapedInfo.fromJson(Map<String, dynamic> json) => ScrapedInfo(
    sourceUrl: json['sourceUrl'],
    lastUpdated: json['lastUpdated'],
    scrapedAt: json['scrapedAt'],
  );

  Map<String, dynamic> toJson() => {
    'sourceUrl': sourceUrl,
    'lastUpdated': lastUpdated,
    'scrapedAt': scrapedAt,
  };
}

// 🎓 The Main Bursary Model - The star of the show!
class Bursary {
  final String id;
  final Provider provider;
  final String title;
  final List<String> fields;
  final String studyLevel;
  final String academicYear;
  final int? numberOfBursaries;
  final Coverage coverage;
  final WorkBackObligation workBackObligation;
  final Deadline deadline;
  final Eligibility eligibility;
  final ApplicationProcess applicationProcess;
  final List<String> requiredDocuments;
  final SelectionProcess selectionProcess;
  final ScrapedInfo scraped;
  final List<String> tags;
  final double? matchScore;
  final bool isSaved;

  Bursary({
    required this.id,
    required this.provider,
    required this.title,
    required this.fields,
    required this.studyLevel,
    required this.academicYear,
    this.numberOfBursaries,
    required this.coverage,
    required this.workBackObligation,
    required this.deadline,
    required this.eligibility,
    required this.applicationProcess,
    required this.requiredDocuments,
    required this.selectionProcess,
    required this.scraped,
    required this.tags,
    this.matchScore,
    required this.isSaved,
  });

  // 🚨 Quick helper to check if this bursary needs urgent attention
  bool get needsUrgentAction => deadline.isUrgent || deadline.isCritical;

  // 💯 Is this a perfect match for the user?
  bool get isPerfectMatch => matchScore != null && matchScore! >= 85;

  factory Bursary.fromJson(Map<String, dynamic> json) => Bursary(
    id: json['id'],
    provider: Provider.fromJson(json['provider']),
    title: json['title'],
    fields: List<String>.from(json['fields'] ?? []),
    studyLevel: json['studyLevel'],
    academicYear: json['academicYear'],
    numberOfBursaries: json['numberOfBursaries'],
    coverage: Coverage.fromJson(json['coverage']),
    workBackObligation: WorkBackObligation.fromJson(json['workBackObligation']),
    deadline: Deadline.fromJson(json['deadline']),
    eligibility: Eligibility.fromJson(json['eligibility']),
    applicationProcess: ApplicationProcess.fromJson(json['applicationProcess']),
    requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
    selectionProcess: SelectionProcess.fromJson(json['selectionProcess']),
    scraped: ScrapedInfo.fromJson(json['scraped']),
    tags: List<String>.from(json['tags'] ?? []),
    matchScore: (json['matchScore'] as num?)?.toDouble(),
    isSaved: json['isSaved'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'provider': provider.toJson(),
    'title': title,
    'fields': fields,
    'studyLevel': studyLevel,
    'academicYear': academicYear,
    'numberOfBursaries': numberOfBursaries,
    'coverage': coverage.toJson(),
    'workBackObligation': workBackObligation.toJson(),
    'deadline': deadline.toJson(),
    'eligibility': eligibility.toJson(),
    'applicationProcess': applicationProcess.toJson(),
    'requiredDocuments': requiredDocuments,
    'selectionProcess': selectionProcess.toJson(),
    'scraped': scraped.toJson(),
    'tags': tags,
    'matchScore': matchScore,
    'isSaved': isSaved,
  };
}

// 📄 Pagination Info - For handling pages of results
class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  // 🎯 Are we on the last page?
  bool get isLastPage => page >= totalPages;

  // 🎯 Are we on the first page?
  bool get isFirstPage => page == 1;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
    total: json['total'],
    page: json['page'],
    limit: json['limit'],
    totalPages: json['totalPages'],
  );

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };
}

// 🔍 Filter Info - Stats about the filtered results
class FilterInfo {
  final int urgentCount;
  final int closingSoon;
  final int totalResults;

  FilterInfo({
    required this.urgentCount,
    required this.closingSoon,
    required this.totalResults,
  });

  // 🚨 Do we have any urgent bursaries to show?
  bool get hasUrgentBursaries => urgentCount > 0;

  factory FilterInfo.fromJson(Map<String, dynamic> json) => FilterInfo(
    urgentCount: json['urgentCount'],
    closingSoon: json['closingSoon'],
    totalResults: json['totalResults'],
  );

  Map<String, dynamic> toJson() => {
    'urgentCount': urgentCount,
    'closingSoon': closingSoon,
    'totalResults': totalResults,
  };
}

// 📦 Bursaries Response - The complete API response
class BursariesResponse {
  final List<Bursary> bursaries;
  final PaginationInfo pagination;
  final FilterInfo filters;

  BursariesResponse({
    required this.bursaries,
    required this.pagination,
    required this.filters,
  });

  factory BursariesResponse.fromJson(Map<String, dynamic> json) =>
      BursariesResponse(
        bursaries: (json['bursaries'] as List)
            .map((e) => Bursary.fromJson(e))
            .toList(),
        pagination: PaginationInfo.fromJson(json['pagination']),
        filters: FilterInfo.fromJson(json['filters']),
      );

  Map<String, dynamic> toJson() => {
    'bursaries': bursaries.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
    'filters': filters.toJson(),
  };
}

// 📚 Field Category - Academic fields/categories
class FieldCategory {
  final String slug;
  final String name;
  final List<String> subcategories;

  FieldCategory({
    required this.slug,
    required this.name,
    required this.subcategories,
  });

  factory FieldCategory.fromJson(Map<String, dynamic> json) => FieldCategory(
    slug: json['slug'],
    name: json['name'],
    subcategories: List<String>.from(json['subcategories'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'name': name,
    'subcategories': subcategories,
  };
}

// 📋 Fields Response - List of all available fields
class FieldsResponse {
  final List<FieldCategory> categories;

  FieldsResponse({required this.categories});

  factory FieldsResponse.fromJson(Map<String, dynamic> json) => FieldsResponse(
    categories: (json['categories'] as List)
        .map((e) => FieldCategory.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'categories': categories.map((e) => e.toJson()).toList(),
  };
}

// 🎯 Closing Soon Item - For bursaries about to close
class ClosingSoonItem {
  final String id;
  final String provider;
  final String title;
  final String? closingDate;
  final String displayText;
  final int daysLeft;
  final bool isUrgent;
  final String field;
  final int amount;

  ClosingSoonItem({
    required this.id,
    required this.provider,
    required this.title,
    this.closingDate,
    required this.displayText,
    required this.daysLeft,
    required this.isUrgent,
    required this.field,
    required this.amount,
  });

  factory ClosingSoonItem.fromJson(Map<String, dynamic> json) =>
      ClosingSoonItem(
        id: json['id'],
        provider: json['provider'],
        title: json['title'],
        closingDate: json['closingDate'],
        displayText: json['displayText'],
        daysLeft: json['daysLeft'],
        isUrgent: json['isUrgent'],
        field: json['field'],
        amount: json['amount'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'provider': provider,
    'title': title,
    'closingDate': closingDate,
    'displayText': displayText,
    'daysLeft': daysLeft,
    'isUrgent': isUrgent,
    'field': field,
    'amount': amount,
  };
}

// 📊 Closing Soon Summary - Stats about closing bursaries
class ClosingSoonSummary {
  final int urgentCount;
  final int thisMonth;
  final int nextMonth;

  ClosingSoonSummary({
    required this.urgentCount,
    required this.thisMonth,
    required this.nextMonth,
  });

  factory ClosingSoonSummary.fromJson(Map<String, dynamic> json) =>
      ClosingSoonSummary(
        urgentCount: json['urgentCount'],
        thisMonth: json['thisMonth'],
        nextMonth: json['nextMonth'],
      );

  Map<String, dynamic> toJson() => {
    'urgentCount': urgentCount,
    'thisMonth': thisMonth,
    'nextMonth': nextMonth,
  };
}

// 🚀 Closing Soon Response - Complete response for closing soon endpoint
class ClosingSoonResponse {
  final List<ClosingSoonItem> closingSoon;
  final ClosingSoonSummary summary;

  ClosingSoonResponse({required this.closingSoon, required this.summary});

  factory ClosingSoonResponse.fromJson(Map<String, dynamic> json) =>
      ClosingSoonResponse(
        closingSoon: (json['closingSoon'] as List)
            .map((e) => ClosingSoonItem.fromJson(e))
            .toList(),
        summary: ClosingSoonSummary.fromJson(json['summary']),
      );

  Map<String, dynamic> toJson() => {
    'closingSoon': closingSoon.map((e) => e.toJson()).toList(),
    'summary': summary.toJson(),
  };
}

// 🏥 Health Response - API health check
class HealthResponse {
  final String status;
  final String timestamp;
  final String service;
  final String targetSite;

  HealthResponse({
    required this.status,
    required this.timestamp,
    required this.service,
    required this.targetSite,
  });

  // ✅ Is the API healthy?
  bool get isHealthy => status.toLowerCase() == 'healthy';

  factory HealthResponse.fromJson(Map<String, dynamic> json) => HealthResponse(
    status: json['status'],
    timestamp: json['timestamp'],
    service: json['service'],
    targetSite: json['targetSite'],
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'timestamp': timestamp,
    'service': service,
    'targetSite': targetSite,
  };
}

// 🌟 API Info Response - Basic API information from root endpoint
class ApiInfo {
  final String service;
  final String version;
  final String baseUrl;
  final String documentation;

  ApiInfo({
    required this.service,
    required this.version,
    required this.baseUrl,
    required this.documentation,
  });

  factory ApiInfo.fromJson(Map<String, dynamic> json) => ApiInfo(
    service: json['service'],
    version: json['version'],
    baseUrl: json['base_url'],
    documentation: json['documentation'],
  );

  Map<String, dynamic> toJson() => {
    'service': service,
    'version': version,
    'base_url': baseUrl,
    'documentation': documentation,
  };
}
