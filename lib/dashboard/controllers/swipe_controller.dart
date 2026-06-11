import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../database/db_helper.dart';
import '../models/dummy_user.dart';

class SwipeController extends GetxController {
  final RxList<DummyUser> deckUsers = <DummyUser>[].obs;
  final RxList<DummyUser> acceptedUsers = <DummyUser>[].obs;
  final RxList<DummyUser> rejectedUsers = <DummyUser>[].obs;
  final RxInt currentTabIndex = 0.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
    if (index == 1) {
      loadSwipedUsersFromDB(); // Refresh matches tab
    }
  }

  // Initial load
  Future<void> loadAllData() async {
    await loadSwipedUsersFromDB();
    await fetchUsersFromAPI();
  }

  // Load saved swipes from SQLite database
  Future<void> loadSwipedUsersFromDB() async {
    try {
      final dbHelper = DatabaseHelper.instance;

      final acceptedMaps = await dbHelper.getSwipesByStatus('accepted');
      acceptedUsers.value = acceptedMaps
          .map((m) => DummyUser.fromMap(m))
          .toList();

      final rejectedMaps = await dbHelper.getSwipesByStatus('rejected');
      rejectedUsers.value = rejectedMaps
          .map((m) => DummyUser.fromMap(m))
          .toList();
    } catch (e) {
      errorMessage.value = 'Failed to load swipes from DB: ${e.toString()}';
    }
  }

  // Fetch users from dummy JSON API
  Future<void> fetchUsersFromAPI() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('https://dummyjson.com/users?limit=100'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> usersList = data['users'] ?? [];

        final List<DummyUser> fetchedUsers = usersList
            .map((userJson) => DummyUser.fromJson(userJson))
            .toList();

        // Get IDs of all users already swiped from SQLite
        final swipedIds = await DatabaseHelper.instance.getAllSwipedIds();

        // Filter out already swiped users
        deckUsers.value = fetchedUsers
            .where((user) => !swipedIds.contains(user.id))
            .toList();
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch users: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Record a swipe (Accept/Reject)
  Future<void> swipeUser(DummyUser user, bool isAccepted) async {
    try {
      final status = isAccepted ? 'accepted' : 'rejected';
      final swipeMap = user.toMap(status);

      // Save to SQLite
      await DatabaseHelper.instance.insertSwipe(swipeMap);

      // Remove from deck list
      deckUsers.removeWhere((u) => u.id == user.id);

      // Add to corresponding local lists
      if (isAccepted) {
        acceptedUsers.insert(0, user);
      } else {
        rejectedUsers.insert(0, user);
      }
    } catch (e) {
      Get.snackbar(
        'Database Error',
        'Failed to record swipe: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Reset all swipes (useful for testing/demo)
  Future<void> resetSwipes() async {
    try {
      isLoading.value = true;
      await DatabaseHelper.instance.clearSwipes();

      acceptedUsers.clear();
      rejectedUsers.clear();

      await fetchUsersFromAPI();
    } catch (e) {
      Get.snackbar(
        'Database Error',
        'Failed to reset swipes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
