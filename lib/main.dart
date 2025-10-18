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
          backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
          activeColor: CupertinoColors.activeOrange,
          inactiveColor: CupertinoColors.systemGrey,
          iconSize: 28.0,
          height: 65.0,
          border: Border(
            top: BorderSide(
              color: CupertinoColors.systemGrey5.resolveFrom(context),
              width: 0.5,
            ),
          ),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.house_fill),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.house_fill),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.person_circle),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.person_circle_fill),
              ),
              label: 'Player',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.flame),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.flame_fill),
              ),
              label: 'Training',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.map),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.map_fill),
              ),
              label: 'Parks',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.chart_bar_circle),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(CupertinoIcons.chart_bar_circle_fill),
              ),
              label: 'Stats',
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