import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../core/validators/creator_validators.dart';
import '../data/models/creator_request.dart';
import '../data/repositories/creator_request_repository.dart';
import '../data/repositories/user_profile_repository.dart';
import '../services/creator_storage_service.dart';

enum CreatorFlowStep {
  formEntry,
  identityUpload,
  guidelinesReview,
  knowledgeTest,
  submitted,
}

class CreatorFormController extends GetxController {
  static const Duration _testRetakeWindow = Duration(hours: 72);

  final CreatorRequestRepository _repository = CreatorRequestRepository();
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  final CreatorStorageService _storageService = CreatorStorageService();

  final Rx<CreatorFlowStep> currentStep = CreatorFlowStep.formEntry.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  final RxBool hasExistingRequest = false.obs;
  final Rxn<CreatorRequest> approvedLocalData = Rxn<CreatorRequest>();

  final RxBool isRetakeBlocked = false.obs;
  final Rxn<DateTime> nextRetakeAllowedAt = Rxn<DateTime>();
  final Rxn<Duration> retakeRemaining = Rxn<Duration>();

  final fullLegalNameController = TextEditingController();
  final countryController = TextEditingController();
  final discordUsernameController = TextEditingController();
  final primaryLanguagesController = TextEditingController();
  final aboutYourselfController = TextEditingController();
  final whyCreatorController = TextEditingController();

  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();

  final RxString identityFileName = ''.obs;
  final Rxn<Uint8List> identityFileBytes = Rxn<Uint8List>();
  final RxString identityFileMimeType = ''.obs;
  final RxString identityDocumentRef = ''.obs;
  final RxString identityDocumentUrl = ''.obs;
  final RxBool identityUploaded = false.obs;

  final RxBool guidelinesAccepted = false.obs;

  final RxBool testCompleted = false.obs;
  final RxBool testPassed = false.obs;
  final RxInt testScore = 0.obs;
  final RxInt testTotalQuestions = 20.obs;

  final RxMap<String, String?> fieldErrors = <String, String?>{}.obs;
  Worker? _authStateWorker;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    _authStateWorker = ever(auth.currentUser, (_) {
      unawaited(_initializeFlowState());
    });
    unawaited(_initializeFlowState());
  }

  @override
  void onClose() {
    fullLegalNameController.dispose();
    countryController.dispose();
    discordUsernameController.dispose();
    primaryLanguagesController.dispose();
    aboutYourselfController.dispose();
    whyCreatorController.dispose();
    _authStateWorker?.dispose();
    super.onClose();
  }

  Future<void> _initializeFlowState() async {
    await _checkExistingRequest();
    await refreshRetakePolicy();
  }

  Future<void> refreshSubmissionState() async {
    await _checkExistingRequest();
  }

  Future<void> _checkExistingRequest() async {
    try {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) {
        hasExistingRequest.value = false;
        approvedLocalData.value = null;
        return;
      }

      final exists = await _repository.hasExistingRequest(auth.userId);
      hasExistingRequest.value = exists;

      if (!exists) {
        return;
      }

      final request = await _repository.fetchByUserId(auth.userId);
      if (request != null && request.status == CreatorRequestStatus.approved) {
        await _userProfileRepository.promoteUserToCreator(userId: auth.userId);
        auth.setCreatorStatus(true);
        approvedLocalData.value = request;
      } else {
        approvedLocalData.value = null;
      }
    } catch (_) {
      // Non-blocking preload.
    }
  }

  Future<void> refreshRetakePolicy() async {
    try {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn) {
        isRetakeBlocked.value = false;
        nextRetakeAllowedAt.value = null;
        retakeRemaining.value = null;
        return;
      }

      final profile = await _userProfileRepository.fetchById(
        auth.userId,
        options: const GetOptions(source: Source.server),
      );
      final lastAttempt = profile?.lastTestAttempt;
      final lastPassed = profile?.lastTestPassed ?? false;

      if (lastAttempt == null || lastPassed) {
        isRetakeBlocked.value = false;
        nextRetakeAllowedAt.value = null;
        retakeRemaining.value = null;
        return;
      }

      final serverNow = await _userProfileRepository.fetchCurrentServerTime(
        auth.userId,
      );
      if (serverNow == null) {
        isRetakeBlocked.value = false;
        nextRetakeAllowedAt.value = null;
        retakeRemaining.value = null;
        return;
      }

      final unlockAt = lastAttempt.add(_testRetakeWindow);
      final blocked = serverNow.isBefore(unlockAt);
      isRetakeBlocked.value = blocked;
      nextRetakeAllowedAt.value = unlockAt;
      retakeRemaining.value = blocked ? unlockAt.difference(serverNow) : null;
    } catch (_) {
      // Non-blocking state check.
    }
  }

  Future<bool> canAccessKnowledgeTest({bool showFeedback = true}) async {
    await refreshRetakePolicy();
    if (!isRetakeBlocked.value) {
      return true;
    }

    if (!showFeedback) {
      return false;
    }

    final remaining = retakeRemaining.value ?? const Duration(hours: 72);
    final unlockAt = nextRetakeAllowedAt.value;
    final unlockText = unlockAt == null
        ? ''
        : ' Next access: ${unlockAt.toUtc().toIso8601String()}.';
    _showError(
      'You can retake the Creator Knowledge Test in '
      '${_formatDuration(remaining)}.$unlockText',
    );
    return false;
  }

  void setDateOfBirth(DateTime date) {
    dateOfBirth.value = date;
    fieldErrors['dateOfBirth'] = CreatorValidators.validateDateOfBirth(date);
  }

  void setIdentityFile({
    required String fileName,
    required Uint8List bytes,
    required String? mimeType,
  }) {
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

  void clearIdentityFile() {
    identityFileName.value = '';
    identityFileBytes.value = null;
    identityFileMimeType.value = '';
    identityUploaded.value = false;
    identityDocumentRef.value = '';
    identityDocumentUrl.value = '';
  }

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

    fieldErrors.removeWhere((_, value) => value == null);
    return fieldErrors.isEmpty;
  }

  void setGuidelinesAccepted(bool accepted) {
    guidelinesAccepted.value = accepted;
  }

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

  Future<bool> handleTestCompletion({
    required int score,
    required int totalQuestions,
    required int requiredScore,
  }) async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      _showError('You must be logged in to complete the test');
      return false;
    }

    if (!await canAccessKnowledgeTest(showFeedback: true)) {
      return false;
    }

    recordTestResult(
      score: score,
      totalQuestions: totalQuestions,
      requiredScore: requiredScore,
    );

    await _recordTestAttempt(passed: testPassed.value);
    await refreshRetakePolicy();

    if (!testPassed.value) {
      _resetLocalData();
      _showError(
        'You scored $score/$totalQuestions. '
        'Required: $requiredScore/$totalQuestions.',
      );
      return false;
    }

    return submitToFirestore();
  }

  Future<bool> submitToFirestore() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      _showError('You must be logged in to submit');
      return false;
    }

    await _checkExistingRequest();
    if (hasExistingRequest.value) {
      return _handleExistingRequest(auth);
    }

    if (!validateForm()) {
      _showError('Please correct the form errors before submitting');
      return false;
    }

    if (!identityUploaded.value) {
      _showError('Please upload your identity document before submitting');
      return false;
    }

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
        status: CreatorRequestStatus.approved,
        guidelinesAccepted: guidelinesAccepted.value,
      );

      await _repository.submitRequest(request);
      await _userProfileRepository.promoteUserToCreator(userId: auth.userId);

      hasExistingRequest.value = true;
      currentStep.value = CreatorFlowStep.submitted;
      _storeApprovedDataLocally(request);
      auth.setCreatorStatus(true);

      _showSuccess(
        'Creator status activated successfully. '
        'Your profile is now eligible for New Buddies.',
      );
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'already-exists') {
        hasExistingRequest.value = true;
        return _handleExistingRequest(auth);
      }
      if (e.code == 'permission-denied') {
        _showError(
          'Submission failed due to Firestore access rules. '
          'Please contact support with code: permission-denied.',
        );
        return false;
      }
      _showError('Submission failed: ${e.message ?? e.code}');
      return false;
    } catch (e) {
      _showError('Submission failed: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

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

  Future<void> _recordTestAttempt({required bool passed}) async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      return;
    }
    await _userProfileRepository.recordCreatorTestAttempt(
      userId: auth.userId,
      passed: passed,
    );
  }

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

  void _storeApprovedDataLocally(CreatorRequest request) {
    approvedLocalData.value = request;
  }

  Future<bool> _handleExistingRequest(AuthController auth) async {
    final existing = await _repository.fetchByUserId(auth.userId);
    if (existing == null) {
      _showError('You have already submitted a creator application');
      return false;
    }

    switch (existing.status) {
      case CreatorRequestStatus.approved:
        await _userProfileRepository.promoteUserToCreator(userId: auth.userId);
        auth.setCreatorStatus(true);
        _storeApprovedDataLocally(existing);
        _showSuccess(
          'Your creator application is already approved. '
          'Your creator account is active.',
        );
        return true;
      case CreatorRequestStatus.pending:
        _showError(
          'Your creator application is already submitted and under review.',
        );
        return false;
      case CreatorRequestStatus.rejected:
        _showError(
          'Your previous creator application was rejected. '
          'Please contact support before reapplying.',
        );
        return false;
    }
  }

  String _formatDuration(Duration duration) {
    final totalMinutes = duration.inMinutes;
    if (totalMinutes <= 0) {
      return '0m';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) {
      return '${minutes}m';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  void _showError(String message) {
    errorMessage.value = message;
    if (Get.context == null) {
      return;
    }
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
    if (Get.context == null) {
      return;
    }
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
