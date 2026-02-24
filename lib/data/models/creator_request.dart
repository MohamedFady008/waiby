import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the status of a creator application request.
enum CreatorRequestStatus {
  pending,
  approved,
  rejected;

  String get value {
    switch (this) {
      case CreatorRequestStatus.pending:
        return 'pending';
      case CreatorRequestStatus.approved:
        return 'approved';
      case CreatorRequestStatus.rejected:
        return 'rejected';
    }
  }

  static CreatorRequestStatus fromString(String? value) {
    switch (value) {
      case 'approved':
        return CreatorRequestStatus.approved;
      case 'rejected':
        return CreatorRequestStatus.rejected;
      default:
        return CreatorRequestStatus.pending;
    }
  }
}

/// Data model for a creator application request.
///
/// Maps directly to the `creator_requests` Firestore collection.
class CreatorRequest {
  final String userId;
  final String fullLegalName;
  final DateTime dateOfBirth;
  final String countryOfResidence;
  final String discordUsername;
  final String primaryLanguages;
  final String aboutYourself;
  final String whyCreator;

  /// Firebase Storage path reference to the uploaded identity document.
  final String? identityDocumentRef;

  /// The URL of the uploaded identity document (download URL).
  final String? identityDocumentUrl;

  /// Original file name of the identity document.
  final String? identityDocumentName;

  /// Whether the user passed the Creator Knowledge Test.
  final bool testPassed;

  /// Score achieved on the Creator Knowledge Test (e.g. 17/20).
  final int testScore;

  /// Total number of questions in the Creator Knowledge Test.
  final int testTotalQuestions;

  /// Current status of the creator request.
  final CreatorRequestStatus status;

  /// Whether the guidelines were accepted.
  final bool guidelinesAccepted;

  /// Server-side timestamp of when the request was created.
  final DateTime? createdAt;

  /// Server-side timestamp of the last update.
  final DateTime? updatedAt;

  const CreatorRequest({
    required this.userId,
    required this.fullLegalName,
    required this.dateOfBirth,
    required this.countryOfResidence,
    required this.discordUsername,
    required this.primaryLanguages,
    required this.aboutYourself,
    required this.whyCreator,
    this.identityDocumentRef,
    this.identityDocumentUrl,
    this.identityDocumentName,
    this.testPassed = false,
    this.testScore = 0,
    this.testTotalQuestions = 20,
    this.status = CreatorRequestStatus.pending,
    this.guidelinesAccepted = false,
    this.createdAt,
    this.updatedAt,
  });

  CreatorRequest copyWith({
    String? userId,
    String? fullLegalName,
    DateTime? dateOfBirth,
    String? countryOfResidence,
    String? discordUsername,
    String? primaryLanguages,
    String? aboutYourself,
    String? whyCreator,
    String? identityDocumentRef,
    String? identityDocumentUrl,
    String? identityDocumentName,
    bool? testPassed,
    int? testScore,
    int? testTotalQuestions,
    CreatorRequestStatus? status,
    bool? guidelinesAccepted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreatorRequest(
      userId: userId ?? this.userId,
      fullLegalName: fullLegalName ?? this.fullLegalName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      countryOfResidence: countryOfResidence ?? this.countryOfResidence,
      discordUsername: discordUsername ?? this.discordUsername,
      primaryLanguages: primaryLanguages ?? this.primaryLanguages,
      aboutYourself: aboutYourself ?? this.aboutYourself,
      whyCreator: whyCreator ?? this.whyCreator,
      identityDocumentRef: identityDocumentRef ?? this.identityDocumentRef,
      identityDocumentUrl: identityDocumentUrl ?? this.identityDocumentUrl,
      identityDocumentName: identityDocumentName ?? this.identityDocumentName,
      testPassed: testPassed ?? this.testPassed,
      testScore: testScore ?? this.testScore,
      testTotalQuestions: testTotalQuestions ?? this.testTotalQuestions,
      status: status ?? this.status,
      guidelinesAccepted: guidelinesAccepted ?? this.guidelinesAccepted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      'user_id': userId,
      'full_legal_name': fullLegalName,
      'date_of_birth': Timestamp.fromDate(dateOfBirth),
      'country_of_residence': countryOfResidence,
      'discord_username': discordUsername,
      'primary_languages': primaryLanguages,
      'about_yourself': aboutYourself,
      'why_creator': whyCreator,
      'identity_document_ref': identityDocumentRef,
      'identity_document_url': identityDocumentUrl,
      'identity_document_name': identityDocumentName,
      'test_passed': testPassed,
      'test_score': testScore,
      'test_total_questions': testTotalQuestions,
      'status': status.value,
      'guidelines_accepted': guidelinesAccepted,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Deserializes a Firestore document into a [CreatorRequest].
  factory CreatorRequest.fromFirestoreMap(Map<String, dynamic> data) {
    DateTime? toDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return CreatorRequest(
      userId: data['user_id']?.toString() ?? '',
      fullLegalName: data['full_legal_name']?.toString() ?? '',
      dateOfBirth: toDateTime(data['date_of_birth']) ?? DateTime(2000),
      countryOfResidence: data['country_of_residence']?.toString() ?? '',
      discordUsername: data['discord_username']?.toString() ?? '',
      primaryLanguages: data['primary_languages']?.toString() ?? '',
      aboutYourself: data['about_yourself']?.toString() ?? '',
      whyCreator: data['why_creator']?.toString() ?? '',
      identityDocumentRef: data['identity_document_ref']?.toString(),
      identityDocumentUrl: data['identity_document_url']?.toString(),
      identityDocumentName: data['identity_document_name']?.toString(),
      testPassed: data['test_passed'] == true,
      testScore: (data['test_score'] as num?)?.toInt() ?? 0,
      testTotalQuestions: (data['test_total_questions'] as num?)?.toInt() ?? 20,
      status: CreatorRequestStatus.fromString(data['status']?.toString()),
      guidelinesAccepted: data['guidelines_accepted'] == true,
      createdAt: toDateTime(data['created_at']),
      updatedAt: toDateTime(data['updated_at']),
    );
  }

  /// Serializes this model to a map for local storage (no FieldValue).
  Map<String, dynamic> toLocalMap() {
    return <String, dynamic>{
      'user_id': userId,
      'full_legal_name': fullLegalName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'country_of_residence': countryOfResidence,
      'discord_username': discordUsername,
      'primary_languages': primaryLanguages,
      'about_yourself': aboutYourself,
      'why_creator': whyCreator,
      'identity_document_ref': identityDocumentRef,
      'identity_document_url': identityDocumentUrl,
      'identity_document_name': identityDocumentName,
      'test_passed': testPassed,
      'test_score': testScore,
      'test_total_questions': testTotalQuestions,
      'status': status.value,
      'guidelines_accepted': guidelinesAccepted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Deserializes from a local storage map.
  factory CreatorRequest.fromLocalMap(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return CreatorRequest(
      userId: data['user_id']?.toString() ?? '',
      fullLegalName: data['full_legal_name']?.toString() ?? '',
      dateOfBirth: parseDate(data['date_of_birth']) ?? DateTime(2000),
      countryOfResidence: data['country_of_residence']?.toString() ?? '',
      discordUsername: data['discord_username']?.toString() ?? '',
      primaryLanguages: data['primary_languages']?.toString() ?? '',
      aboutYourself: data['about_yourself']?.toString() ?? '',
      whyCreator: data['why_creator']?.toString() ?? '',
      identityDocumentRef: data['identity_document_ref']?.toString(),
      identityDocumentUrl: data['identity_document_url']?.toString(),
      identityDocumentName: data['identity_document_name']?.toString(),
      testPassed: data['test_passed'] == true,
      testScore: (data['test_score'] as num?)?.toInt() ?? 0,
      testTotalQuestions: (data['test_total_questions'] as num?)?.toInt() ?? 20,
      status: CreatorRequestStatus.fromString(data['status']?.toString()),
      guidelinesAccepted: data['guidelines_accepted'] == true,
      createdAt: parseDate(data['created_at']),
      updatedAt: parseDate(data['updated_at']),
    );
  }
}
