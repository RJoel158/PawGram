import 'package:flutter/material.dart';
import 'auth/home/feed_page.dart';
import 'auth/posts/create_post_page.dart';
import 'auth/profile/profile_page.dart';
import 'theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [FeedPage(), CreatePostPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: isLargeScreen
          ? Row(
              children: [
                // Sidebar para pantallas grandes
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: AppColors.cream,
                  elevation: 1,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.add_box_outlined),
                      selectedIcon: Icon(Icons.add_box),
                      label: Text('Crear'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Perfil'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Contenido principal
                Expanded(
                  child: _pages[_currentIndex],
                ),
              ],
            )
          : _pages[_currentIndex],
      // BottomNavigationBar solo para pantallas pequeñas
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              selectedItemColor: AppColors.paddingtonBlue,
              unselectedItemColor: AppColors.muted,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_box), label: 'Crear'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Perfil'),
              ],
            ),
    );
  }
}
