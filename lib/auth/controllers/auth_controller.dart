import 'package:get/get.dart';
import '../../database/db_helper.dart';
import '../models/user_model.dart';
import '../../core/shared_prefs.dart';
import '../../core/app_constants.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final RxBool isLoggedIn = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // Check SharedPreferences if user is already logged in
  Future<void> checkLoginStatus() async {
    final loggedIn = SharedPrefs.getBool(StorageKeys.isLoggedIn);
    final email = SharedPrefs.getString(StorageKeys.loggedInEmail);

    if (loggedIn && email != null) {
      // Load user details from SQLite database
      final userMap = await DatabaseHelper.instance.getUserByEmail(email);
      if (userMap != null) {
        currentUser.value = UserModel.fromMap(userMap);
        isLoggedIn.value = true;
      } else {
        isLoggedIn.value = false;
        await SharedPrefs.setBool(StorageKeys.isLoggedIn, false);
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
      await SharedPrefs.setBool(StorageKeys.isLoggedIn, true);
      await SharedPrefs.setString(StorageKeys.loggedInEmail, email);

      final createdUser = await dbHelper.getUserByEmail(email);
      if (createdUser != null) {
        currentUser.value = UserModel.fromMap(createdUser);
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

      final user = UserModel.fromMap(userMap);
      if (user.password != password) {
        isLoading.value = false;
        return 'Incorrect password';
      }

      // Set session after successful login
      await SharedPrefs.setBool(StorageKeys.isLoggedIn, true);
      await SharedPrefs.setString(StorageKeys.loggedInEmail, email);

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
    await SharedPrefs.setBool(StorageKeys.isLoggedIn, false);
    await SharedPrefs.remove(StorageKeys.loggedInEmail);

    currentUser.value = null;
    isLoggedIn.value = false;

    Get.offAllNamed('/login');
  }
}
