import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/user_profile_repository.dart';

class HomeController extends GetxController {
  HomeController({UserProfileRepository? userProfileRepository})
    : _userProfileRepository = userProfileRepository ?? UserProfileRepository();

  final UserProfileRepository _userProfileRepository;

  final RxList<UserProfile> newestCreators = <UserProfile>[].obs;
  final RxList<UserProfile> proGamers = <UserProfile>[].obs;

  final RxBool loadingNewestCreators = true.obs;
  final RxBool loadingProGamers = true.obs;

  final RxString newestCreatorsError = ''.obs;
  final RxString proGamersError = ''.obs;

  StreamSubscription<List<UserProfile>>? _newestCreatorsSubscription;
  StreamSubscription<List<UserProfile>>? _proGamersSubscription;

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
  }

  @override
  void onClose() {
    unawaited(_newestCreatorsSubscription?.cancel());
    unawaited(_proGamersSubscription?.cancel());
    super.onClose();
  }

  void _bindStreams() {
    _newestCreatorsSubscription = _userProfileRepository
        .watchNewestCreators(limit: 12)
        .listen(
          (users) {
            newestCreators.assignAll(users);
            loadingNewestCreators.value = false;
            newestCreatorsError.value = '';
          },
          onError: (error) {
            loadingNewestCreators.value = false;
            newestCreatorsError.value =
                'Failed to load New Buddies. Please try again.';
            debugPrint('HomeController.watchNewestCreators error: $error');
          },
        );

    _proGamersSubscription = _userProfileRepository
        .watchProGamers(limit: 8)
        .listen(
          (users) {
            proGamers.assignAll(users);
            loadingProGamers.value = false;
            proGamersError.value = '';
          },
          onError: (error) {
            loadingProGamers.value = false;
            proGamersError.value =
                'Failed to load Pro Gamers. Please try again.';
            debugPrint('HomeController.watchProGamers error: $error');
          },
        );
  }
}
