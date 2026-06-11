import 'package:get/get.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import 'app_user.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final RxBool isLoggedIn = false.obs;
  final Rxn<AppUser> currentUser = Rxn<AppUser>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // Check SharedPreferences if user is already logged in
  Future<void> checkLoginStatus() async {
    final storage = StorageService.to;
    final loggedIn = storage.getBool('isLoggedIn');
    final email = storage.getString('loggedInEmail');

    if (loggedIn && email != null) {
      // Load user details from SQLite database
      final userMap = await DatabaseHelper.instance.getUserByEmail(email);
      if (userMap != null) {
        currentUser.value = AppUser.fromMap(userMap);
        isLoggedIn.value = true;
      } else {
        isLoggedIn.value = false;
        storage.setBool('isLoggedIn', false);
      }
    } else {
      isLoggedIn.value = false;
    }
  }

  // Register user into local SQLite database
  Future<String?> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      isLoading.value = true;
      final dbHelper = DatabaseHelper.instance;

      // Check if user already exists
      final existingUser = await dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        isLoading.value = false;
        return 'Email already registered';
      }

      // Insert user
      final userMap = {'name': name, 'email': email, 'password': password};
      await dbHelper.insertUser(userMap);

      // Set session after successful registration
      final storage = StorageService.to;
      await storage.setBool('isLoggedIn', true);
      await storage.setString('loggedInEmail', email);

      final createdUser = await dbHelper.getUserByEmail(email);
      if (createdUser != null) {
        currentUser.value = AppUser.fromMap(createdUser);
      }
      isLoggedIn.value = true;

      isLoading.value = false;
      return null; // Success
    } catch (e) {
      isLoading.value = false;
      return 'Registration failed: ${e.toString()}';
    }
  }

  // Login user matching DB credentials
  Future<String?> loginUser(String email, String password) async {
    try {
      isLoading.value = true;
      final dbHelper = DatabaseHelper.instance;

      final userMap = await dbHelper.getUserByEmail(email);
      if (userMap == null) {
        isLoading.value = false;
        return 'Email not found. Please register first.';
      }

      final user = AppUser.fromMap(userMap);
      if (user.password != password) {
        isLoading.value = false;
        return 'Incorrect password';
      }

      // Set session after successful login
      final storage = StorageService.to;
      await storage.setBool('isLoggedIn', true);
      await storage.setString('loggedInEmail', email);

      currentUser.value = user;
      isLoggedIn.value = true;

      isLoading.value = false;
      return null; // Success
    } catch (e) {
      isLoading.value = false;
      return 'Login failed: ${e.toString()}';
    }
  }

  // Logout and clear session
  Future<void> logout() async {
    final storage = StorageService.to;
    await storage.setBool('isLoggedIn', false);
    await storage.remove('loggedInEmail');

    currentUser.value = null;
    isLoggedIn.value = false;

    Get.offAllNamed('/login');
  }
}
