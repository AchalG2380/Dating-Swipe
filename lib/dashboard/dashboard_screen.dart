import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/core/app_strings.dart';
import '../auth/auth_controller.dart';
import 'swipe_controller.dart';
import 'dummy_user.dart';
import 'swipe_card.dart';
import 'package:task/core/app_color.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register SwipeController once for the whole dashboard
    final swipeController = Get.put(SwipeController());
    const tabs = [_SwipeTab(), _MatchesTab(), _ProfileTab()];

    return Obx(
      () => Scaffold(
        backgroundColor: AppColor.background,
        body: IndexedStack(
          index: swipeController.currentTabIndex.value,
          children: tabs,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: swipeController.currentTabIndex.value,
          onTap: swipeController.changeTab,
          backgroundColor: AppColor.background,
          selectedItemColor: AppColor.primary,
          unselectedItemColor: Colors.white.withValues(alpha: 0.4),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore, color: AppColor.primary),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite, color: AppColor.primary),
              label: 'Matches',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppColor.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ACTION BUTTON WIDGET
// ==========================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isSmall;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isSmall = false,
  });
  @override
  Widget build(BuildContext context) {
    final size = isSmall ? 52.0 : 68.0;
    final iconSize = isSmall ? 24.0 : 32.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: onPressed != null
              ? color.withValues(alpha: 0.3)
              : Colors.white12,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: onPressed != null ? color : Colors.white24,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

// --- SWIPE TAB ---

class _SwipeTab extends StatelessWidget {
  const _SwipeTab();

  @override
  Widget build(BuildContext context) {
    final swipeController = Get.find<SwipeController>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.favorite, color: AppColor.primary, size: 28),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: () => swipeController.fetchUsersFromAPI(),
                  tooltip: 'Reload Deck',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card Stack Area
            Expanded(
              child: Obx(() {
                if (swipeController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColor.primary),
                  );
                }

                if (swipeController.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          swipeController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => swipeController.loadAllData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final users = swipeController.deckUsers;

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.supervised_user_circle_outlined,
                          size: 80,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No more profiles around you!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap below to reset your swipe history\nand explore profiles again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => swipeController.resetSwipes(),
                          icon: const Icon(Icons.restore),
                          label: const Text('Reset Swipe History'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final count = users.length.clamp(0, 2);
                return Stack(
                  children: List.generate(count, (index) {
                    // Render in reverse so top card sits at the front
                    final reversedIndex = count - 1 - index;
                    final user = users[reversedIndex];
                    final isFront = reversedIndex == 0;

                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      top: isFront ? 0.0 : 12.0,
                      bottom: isFront ? 0.0 : 4.0,
                      left: isFront ? 0.0 : 8.0,
                      right: isFront ? 0.0 : 8.0,
                      child: Transform.scale(
                        scale: isFront ? 1.0 : 0.96,
                        child: SwipeCard(
                          key: ValueKey(user.id),
                          user: user,
                          isFrontCard: isFront,
                          onSwipe: (isAccepted) {
                            swipeController.swipeUser(user, isAccepted);
                          },
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Obx(() {
              final users = swipeController.deckUsers;
              final hasUsers =
                  users.isNotEmpty && !swipeController.isLoading.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nope Button
                  _ActionButton(
                    icon: Icons.close,
                    color: AppColor.error,
                    onPressed: hasUsers
                        ? () {
                            final topUser = users.first;
                            swipeController.swipeUser(topUser, false);
                          }
                        : null,
                  ),
                  const SizedBox(width: 24),
                  // Reset / Reload Button
                  _ActionButton(
                    icon: Icons.rotate_left,
                    color: Colors.blueAccent,
                    isSmall: true,
                    onPressed: () {
                      swipeController.resetSwipes();
                    },
                  ),
                  const SizedBox(width: 24),
                  // Like Button
                  _ActionButton(
                    icon: Icons.favorite,
                    color: Colors.greenAccent,
                    onPressed: hasUsers
                        ? () {
                            final topUser = users.first;
                            swipeController.swipeUser(topUser, true);
                          }
                        : null,
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// --- PROFILE TAB ---

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;
    final swipeController = Get.find<SwipeController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar Placeholder
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColor.primary, AppColor.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        auth.currentUser.value?.name.isNotEmpty == true
                            ? auth.currentUser.value!.name
                                  .substring(0, 1)
                                  .toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile info text
            Text(
              auth.currentUser.value?.name ?? 'User Name',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              auth.currentUser.value?.email ?? 'user@example.com',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),

            // Settings options list
            _buildProfileOption(
              context,
              icon: Icons.verified_user_outlined,
              title: 'Account Status',
              subtitle: 'Active member',
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.5),
                  ),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              context,
              icon: Icons.history,
              title: 'Swipe Stats',
              subtitle: 'View local data resets',
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    backgroundColor: AppColor.surface,
                    title: const Text(
                      'Reset Swipes?',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'This will delete all swipes from your local database and load users fresh from the API.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          swipeController.resetSwipes();
                          Get.back();
                          Get.snackbar(
                            'Reset Successful',
                            'Swipe database has been cleared!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.blueAccent,
                            colorText: Colors.white,
                          );
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: AppColor.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
              context,
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'SQLite secure credentials storage',
            ),

            const SizedBox(height: 50),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.error.withValues(alpha: 0.1),
                foregroundColor: AppColor.error,
                side: const BorderSide(color: AppColor.error, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColor.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3),
            ),
      ),
    );
  }
}

class _MatchesTab extends StatelessWidget {
  const _MatchesTab();

  @override
  Widget build(BuildContext context) {
    final swipeController = Get.find<SwipeController>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColor.background,
        appBar: AppBar(
          backgroundColor: AppColor.background,
          title: const Text(
            'My Swipes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            dividerColor: Colors.white.withValues(alpha: 0.08),
            indicatorColor: AppColor.primary,
            labelColor: AppColor.primary,
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, size: 18),
                    SizedBox(width: 8),
                    Text(AppStrings.Liked),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.heart_broken, size: 18),
                    SizedBox(width: 8),
                    Text(AppStrings.Noped),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Obx(() => _buildMatchesGrid(swipeController.acceptedUsers, true)),
            Obx(() => _buildMatchesGrid(swipeController.rejectedUsers, false)),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesGrid(List<DummyUser> usersList, bool isLiked) {
    if (usersList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLiked ? Icons.favorite_border : Icons.heart_broken_outlined,
              size: 56,
              color: Colors.white24,
            ),
            const SizedBox(height: 12),
            Text(
              isLiked ? "No liked profiles yet" : "No noped profiles yet",
              style: const TextStyle(color: Colors.white54, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: usersList.length,
      itemBuilder: (context, index) {
        final user = usersList[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Picture
                Image.network(
                  user.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColor.surface,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white38,
                      size: 40,
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Status indicator dot
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isLiked
                          ? AppColor.likeGreen.withValues(alpha: 0.8)
                          : AppColor.nopeRed.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isLiked ? 'LIKED' : 'NOPED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Text info
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName}, ${user.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColor.primary,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              user.city,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
