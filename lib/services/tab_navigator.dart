import 'package:flutter/cupertino.dart';

class TabNavigator extends InheritedWidget {
  final CupertinoTabController tabController;
  
  const TabNavigator({
    super.key,
    required this.tabController,
    required super.child,
  });
  
  static TabNavigator? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabNavigator>();
  }
  
  @override
  bool updateShouldNotify(TabNavigator oldWidget) {
    return tabController != oldWidget.tabController;
  }
}