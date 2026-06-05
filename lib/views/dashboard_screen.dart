import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/swipe_controller.dart';
import '../models/dummy_user.dart';
import 'widgets/swipe_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final swipeController = Get.put(SwipeController());

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildSwipeTab(),
      _buildMatchesTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Refresh lists when entering matches tab
            if (index == 1) {
              swipeController.loadSwipedUsersFromDB();
            }
          },
          backgroundColor: const Color(0xFF0F0C20),
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.white.withOpacity(0.4),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore, color: Colors.pinkAccent),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite, color: Colors.pinkAccent),
              label: 'Matches',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: Colors.pinkAccent),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // --- SWIPE TAB ---

  Widget _buildSwipeTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.pinkAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'HeartSync',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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
                    child: CircularProgressIndicator(color: Colors.pinkAccent),
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
                            backgroundColor: Colors.pinkAccent,
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
                            backgroundColor: Colors.pinkAccent,
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

                return Stack(
                  children: List.generate(users.length > 2 ? 2 : users.length, (
                    index,
                  ) {
                    // Render in reverse so top card sits at the front
                    final reversedIndex =
                        (users.length > 2 ? 2 : users.length) - 1 - index;
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
                  _buildActionButton(
                    icon: Icons.close,
                    color: Colors.redAccent,
                    onPressed: hasUsers
                        ? () {
                            final topUser = users.first;
                            swipeController.swipeUser(topUser, false);
                          }
                        : null,
                  ),
                  const SizedBox(width: 24),
                  // Reset / Reload Button
                  _buildActionButton(
                    icon: Icons.rotate_left,
                    color: Colors.blueAccent,
                    isSmall: true,
                    onPressed: () {
                      swipeController.resetSwipes();
                    },
                  ),
                  const SizedBox(width: 24),
                  // Like Button
                  _buildActionButton(
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isSmall = false,
  }) {
    final size = isSmall ? 52.0 : 68.0;
    final iconSize = isSmall ? 24.0 : 32.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E1E2C),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: onPressed != null ? color.withOpacity(0.3) : Colors.white12,
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

  // --- MATCHES TAB ---

  Widget _buildMatchesTab() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0C20),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F0C20),
          title: const Text(
            'My Swipes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            dividerColor: Colors.white.withOpacity(0.08),
            indicatorColor: Colors.pinkAccent,
            labelColor: Colors.pinkAccent,
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, size: 18),
                    SizedBox(width: 8),
                    Text('Liked'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.heart_broken, size: 18),
                    SizedBox(width: 8),
                    Text('Noped'),
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
            border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                    color: const Color(0xFF1E1E2C),
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
                        Colors.black.withOpacity(0.75),
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
                          ? Colors.green.withOpacity(0.8)
                          : Colors.red.withOpacity(0.8),
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
                            color: Colors.pinkAccent,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              user.city,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
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

  // --- PROFILE TAB ---

  Widget _buildProfileTab() {
    final auth = AuthController.to;

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
                        colors: [Colors.pinkAccent, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.2),
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
                        color: Colors.pinkAccent,
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
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),

            // Settings options list
            _buildProfileOption(
              icon: Icons.verified_user_outlined,
              title: 'Account Status',
              subtitle: 'Active member',
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
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
              icon: Icons.history,
              title: 'Swipe Stats',
              subtitle: 'View local data resets',
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    backgroundColor: const Color(0xFF1E1E2C),
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
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildProfileOption(
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
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
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

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.pinkAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.pinkAccent, size: 22),
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
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
        ),
        trailing:
            trailing ??
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
      ),
    );
  }
}
