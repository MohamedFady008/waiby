import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../core/validators/creator_validators.dart';
import '../data/models/creator_request.dart';
import '../data/repositories/creator_request_repository.dart';
import '../services/creator_storage_service.dart';

/// Managed workflow states for the Become a Creator flow.
enum CreatorFlowStep {
  formEntry,
  identityUpload,
  guidelinesReview,
  knowledgeTest,
  submitted,
}

/// GetX controller that manages the full Become a Creator workflow.
///
/// Responsibilities:
/// - Collects and validates creator form data locally.
/// - Manages identity document upload to Firebase Storage.
/// - Tracks Creator Knowledge Test results.
/// - Submits data to Firestore only if the test is passed.
/// - Stores approved creator data locally for fast access.
/// - Prevents duplicate submissions.
class CreatorFormController extends GetxController {
  final CreatorRequestRepository _repository = CreatorRequestRepository();
  final CreatorStorageService _storageService = CreatorStorageService();

  // ── Observable state ───────────────────────────────────────────────

  final Rx<CreatorFlowStep> currentStep = CreatorFlowStep.formEntry.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  /// Tracks whether the user already has a submitted request.
  final RxBool hasExistingRequest = false.obs;

  /// Cached approved creator data for performance (local only).
  final Rxn<CreatorRequest> approvedLocalData = Rxn<CreatorRequest>();

  // ── Form field controllers ─────────────────────────────────────────

  final fullLegalNameController = TextEditingController();
  final countryController = TextEditingController();
  final discordUsernameController = TextEditingController();
  final primaryLanguagesController = TextEditingController();
  final aboutYourselfController = TextEditingController();
  final whyCreatorController = TextEditingController();

  /// Selected date of birth.
  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();

  // ── Identity document state ────────────────────────────────────────

  final RxString identityFileName = ''.obs;
  final Rxn<Uint8List> identityFileBytes = Rxn<Uint8List>();
  final RxString identityFileMimeType = ''.obs;

  /// After upload: Firebase Storage path reference.
  final RxString identityDocumentRef = ''.obs;

  /// After upload: public download URL.
  final RxString identityDocumentUrl = ''.obs;

  final RxBool identityUploaded = false.obs;

  // ── Guidelines acceptance ──────────────────────────────────────────

  final RxBool guidelinesAccepted = false.obs;

  // ── Knowledge test results ─────────────────────────────────────────

  final RxBool testCompleted = false.obs;
  final RxBool testPassed = false.obs;
  final RxInt testScore = 0.obs;
  final RxInt testTotalQuestions = 20.obs;

  // ── Validation error per field ─────────────────────────────────────

  final RxMap<String, String?> fieldErrors = <String, String?>{}.obs;

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _checkExistingRequest();
  }

  @override
  void onClose() {
    fullLegalNameController.dispose();
    countryController.dispose();
    discordUsernameController.dispose();
    primaryLanguagesController.dispose();
    aboutYourselfController.dispose();
    whyCreatorController.dispose();
    super.onClose();
  }

  // ── Public API ─────────────────────────────────────────────────────

  /// Checks if the current user already has a submitted creator request.
  Future<void> _checkExistingRequest() async {
    try {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) return;

      final exists = await _repository.hasExistingRequest(auth.userId);
      hasExistingRequest.value = exists;

      if (exists) {
        final request = await _repository.fetchByUserId(auth.userId);
        if (request != null &&
            request.status == CreatorRequestStatus.approved) {
          approvedLocalData.value = request;
        }
      }
    } catch (_) {
      // Silently fail – non-blocking check.
    }
  }

  /// Sets the selected date of birth.
  void setDateOfBirth(DateTime date) {
    dateOfBirth.value = date;
    fieldErrors['dateOfBirth'] = CreatorValidators.validateDateOfBirth(date);
  }

  /// Sets the picked identity document file (in memory, not uploaded yet).
  void setIdentityFile({
    required String fileName,
    required Uint8List bytes,
    required String? mimeType,
  }) {
    // Validate before accepting.
    final extError = CreatorValidators.validateFileExtension(fileName);
    if (extError != null) {
      _showError(extError);
      return;
    }
    final sizeError = CreatorValidators.validateFileSize(bytes.length);
    if (sizeError != null) {
      _showError(sizeError);
      return;
    }

    identityFileName.value = fileName;
    identityFileBytes.value = bytes;
    identityFileMimeType.value = mimeType ?? '';
    identityUploaded.value = false;
    identityDocumentRef.value = '';
    identityDocumentUrl.value = '';
  }

  /// Clears the selected identity document.
  void clearIdentityFile() {
    identityFileName.value = '';
    identityFileBytes.value = null;
    identityFileMimeType.value = '';
    identityUploaded.value = false;
    identityDocumentRef.value = '';
    identityDocumentUrl.value = '';
  }

  /// Uploads the selected identity document to Firebase Storage.
  Future<bool> uploadIdentityDocument() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      _showError('You must be logged in to upload documents');
      return false;
    }

    final bytes = identityFileBytes.value;
    if (bytes == null || bytes.isEmpty) {
      _showError('Please select an identity document first');
      return false;
    }

    try {
      isUploading.value = true;
      errorMessage.value = '';

      final result = await _storageService.uploadIdentityDocument(
        userId: auth.userId,
        fileName: identityFileName.value,
        fileBytes: bytes,
        mimeType: identityFileMimeType.value.isEmpty
            ? null
            : identityFileMimeType.value,
      );

      if (!result.success) {
        _showError(result.errorMessage ?? 'Upload failed');
        return false;
      }

      identityDocumentRef.value = result.storagePath ?? '';
      identityDocumentUrl.value = result.downloadUrl ?? '';
      identityUploaded.value = true;
      _showSuccess('Identity document uploaded successfully');
      return true;
    } catch (e) {
      _showError('Upload error: $e');
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  /// Validates all form fields. Returns true if all fields are valid.
  bool validateForm() {
    fieldErrors.clear();

    fieldErrors['fullLegalName'] = CreatorValidators.validateFullLegalName(
      fullLegalNameController.text,
    );
    fieldErrors['dateOfBirth'] = CreatorValidators.validateDateOfBirth(
      dateOfBirth.value,
    );
    fieldErrors['country'] = CreatorValidators.validateCountry(
      countryController.text,
    );
    fieldErrors['discordUsername'] = CreatorValidators.validateDiscordUsername(
      discordUsernameController.text,
    );
    fieldErrors['primaryLanguages'] =
        CreatorValidators.validatePrimaryLanguages(
          primaryLanguagesController.text,
        );
    fieldErrors['aboutYourself'] = CreatorValidators.validateAboutYourself(
      aboutYourselfController.text,
    );
    fieldErrors['whyCreator'] = CreatorValidators.validateWhyCreator(
      whyCreatorController.text,
    );

    // Remove null entries so we can easily check if any errors exist.
    fieldErrors.removeWhere((_, v) => v == null);

    return fieldErrors.isEmpty;
  }

  /// Sets the acceptance state of the creator guidelines.
  void setGuidelinesAccepted(bool accepted) {
    guidelinesAccepted.value = accepted;
  }

  /// Records the result of the Creator Knowledge Test.
  void recordTestResult({
    required int score,
    required int totalQuestions,
    required int requiredScore,
  }) {
    testScore.value = score;
    testTotalQuestions.value = totalQuestions;
    testCompleted.value = true;
    testPassed.value = score >= requiredScore;
  }

  /// The main submission method. Called after the Knowledge Test completes.
  ///
  /// - If the user **passed** the test: submits all data to Firestore.
  /// - If the user **failed** the test: clears temporary data.
  Future<bool> handleTestCompletion({
    required int score,
    required int totalQuestions,
    required int requiredScore,
  }) async {
    recordTestResult(
      score: score,
      totalQuestions: totalQuestions,
      requiredScore: requiredScore,
    );

    if (!testPassed.value) {
      // ❌ User failed – clear temporary local data.
      _resetLocalData();
      _showError(
        'You scored $score/$totalQuestions. '
        'Required: $requiredScore/$totalQuestions. '
        'Your temporary data has been cleared.',
      );
      return false;
    }

    // ✅ User passed – submit to Firestore.
    return submitToFirestore();
  }

  /// Submits the creator request to Cloud Firestore.
  ///
  /// Only called when the test is passed. Prevents duplicate submissions.
  Future<bool> submitToFirestore() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      _showError('You must be logged in to submit');
      return false;
    }

    // Prevent duplicate submissions.
    if (hasExistingRequest.value) {
      _showError('You have already submitted a creator application');
      return false;
    }

    // Validate form fields one final time.
    if (!validateForm()) {
      _showError('Please correct the form errors before submitting');
      return false;
    }

    // Identity document must be uploaded.
    if (!identityUploaded.value) {
      _showError('Please upload your identity document before submitting');
      return false;
    }

    // Guidelines must be accepted.
    if (!guidelinesAccepted.value) {
      _showError('You must accept the Creator Guidelines before submitting');
      return false;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final request = CreatorRequest(
        userId: auth.userId,
        fullLegalName: fullLegalNameController.text.trim(),
        dateOfBirth: dateOfBirth.value!,
        countryOfResidence: countryController.text.trim(),
        discordUsername: discordUsernameController.text.trim(),
        primaryLanguages: primaryLanguagesController.text.trim(),
        aboutYourself: aboutYourselfController.text.trim(),
        whyCreator: whyCreatorController.text.trim(),
        identityDocumentRef: identityDocumentRef.value,
        identityDocumentUrl: identityDocumentUrl.value,
        identityDocumentName: identityFileName.value,
        testPassed: testPassed.value,
        testScore: testScore.value,
        testTotalQuestions: testTotalQuestions.value,
        status: CreatorRequestStatus.pending,
        guidelinesAccepted: guidelinesAccepted.value,
      );

      await _repository.submitRequest(request);

      hasExistingRequest.value = true;
      currentStep.value = CreatorFlowStep.submitted;

      // Store locally for performance.
      _storeApprovedDataLocally(request);

      // Update creator status on the auth controller.
      auth.setCreatorStatus(false); // Still pending, not yet approved.

      _showSuccess(
        'Your creator application has been submitted successfully! '
        'You will receive an update within 48 hours.',
      );
      return true;
    } catch (e) {
      _showError('Submission failed: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Builds a [CreatorRequest] from the current local state.
  /// Useful for previewing what would be submitted.
  CreatorRequest buildLocalRequest() {
    final auth = Get.find<AuthController>();
    return CreatorRequest(
      userId: auth.isLoggedIn ? auth.userId : '',
      fullLegalName: fullLegalNameController.text.trim(),
      dateOfBirth: dateOfBirth.value ?? DateTime(2000),
      countryOfResidence: countryController.text.trim(),
      discordUsername: discordUsernameController.text.trim(),
      primaryLanguages: primaryLanguagesController.text.trim(),
      aboutYourself: aboutYourselfController.text.trim(),
      whyCreator: whyCreatorController.text.trim(),
      identityDocumentRef: identityDocumentRef.value,
      identityDocumentUrl: identityDocumentUrl.value,
      identityDocumentName: identityFileName.value,
      testPassed: testPassed.value,
      testScore: testScore.value,
      testTotalQuestions: testTotalQuestions.value,
      status: CreatorRequestStatus.pending,
      guidelinesAccepted: guidelinesAccepted.value,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────

  /// Clears all temporary local data (called when the test is failed).
  void _resetLocalData() {
    fullLegalNameController.clear();
    countryController.clear();
    discordUsernameController.clear();
    primaryLanguagesController.clear();
    aboutYourselfController.clear();
    whyCreatorController.clear();
    dateOfBirth.value = null;
    clearIdentityFile();
    guidelinesAccepted.value = false;
    testCompleted.value = false;
    testPassed.value = false;
    testScore.value = 0;
    fieldErrors.clear();
    currentStep.value = CreatorFlowStep.formEntry;
  }

  /// Stores the submitted request locally for quick access.
  void _storeApprovedDataLocally(CreatorRequest request) {
    approvedLocalData.value = request;
  }

  void _showError(String message) {
    errorMessage.value = message;
    if (Get.context == null) return;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  void _showSuccess(String message) {
    successMessage.value = message;
    if (Get.context == null) return;
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }
}
