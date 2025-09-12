import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'services/game_provider.dart';
import 'services/tab_navigator.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'screens/training_screen.dart';
import 'screens/parks_screen.dart';
import 'screens/match_screen.dart';

void main() {
  runApp(const MyHoopster());
}

class MyHoopster extends StatelessWidget {
  const MyHoopster({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const CupertinoApp(
        title: 'My Hoopster',
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeOrange,
          barBackgroundColor: CupertinoColors.systemBackground,
        ),
        home: MainTabScaffold(),
      ),
    );
  }
}

class MainTabScaffold extends StatefulWidget {
  const MainTabScaffold({super.key});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  final CupertinoTabController _tabController = CupertinoTabController();

  @override
  Widget build(BuildContext context) {
    return TabNavigator(
      tabController: _tabController,
      child: CupertinoTabScaffold(
        controller: _tabController,
        tabBar: CupertinoTabBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_fill),
              label: 'Player',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.sportscourt),
              label: 'Training',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.location_fill),
              label: 'Parks',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.game_controller_solid),
              label: 'Match',
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) {
              switch (index) {
                case 0:
                  return const HomeScreen();
                case 1:
                  return const PlayerScreen();
                case 2:
                  return const TrainingScreen();
                case 3:
                  return const ParksScreen();
                case 4:
                  return const MatchScreen();
                default:
                  return const HomeScreen();
              }
            },
          );
        },
      ),
    );
  }
}