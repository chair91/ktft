import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kitty/bloc/database_bloc/database_bloc.dart';
import 'package:kitty/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:kitty/database/database_repository.dart';
import 'package:kitty/pages/add_entry/add_entry.dart';
import 'package:kitty/pages/home_page/home_page.dart';
import 'package:kitty/pages/settings_page/settings_page.dart';
import 'package:kitty/pages/statistics_page/statistics_page.dart';
import 'package:kitty/resources/app_icons.dart';
import 'package:kitty/routes/app_routes.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  static const routeName = 'main_page';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const List<String> _pages = [
    StatisticsPage.routeName,
    HomePage.routeName,
    SettingsPage.routeName,
    AddEntry.routeName,
  ];
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  void _onSelectTab(int index) {
    if (_navigatorKey.currentState != null) {
      _navigatorKey.currentState!
          .pushNamedAndRemoveUntil(_pages[index], (_) => false);
    }
  }

  Future<bool> _maybePop() async {
    return await _navigatorKey.currentState!.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DatabaseBloc>(
            create: (_) =>
                DatabaseBloc(DatabaseRepository())..add(CallAllDataEvent())),
        BlocProvider<NavigationBloc>(
          create: (_) => NavigationBloc(),
        ),
      ],
      child: BlocConsumer<NavigationBloc, NavigationState>(
        listener: (_, state) {
          if (state.status == NavigationStateStatus.tab) {
            _onSelectTab(state.currentIndex);
          }
          // if (state.status == NavigationStateStatus.initial) {
          //   _onInitialTab(HomePage.routeName);
          // }
          // if (state.status == NavigationStateStatus.pop) {
          //   _onPopTab();
          // }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              final bool maybePop = await _maybePop();
              if (!maybePop && mounted) {
                context.read<NavigationBloc>().add(NavigationPop());
              }
              return maybePop;
            },
            child: Scaffold(
              key: _key,
              body: Navigator(
                key: _navigatorKey,
                initialRoute: HomePage.routeName,
                onGenerateRoute: AppRoutes.generateRoute,
              ),
              bottomNavigationBar: [0, 1, 2].contains(state.currentIndex)
                  ? BottomNavigationBar(
                      onTap: (int index) {
                        context.read<NavigationBloc>().add(
                            NavigateTab(tabIndex: index, route: _pages[index]));
                      },
                      currentIndex: state.currentIndex,
                      items: [
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(AppIcons.pieChart),
                          activeIcon: SvgPicture.asset(AppIcons.pieChartFilled),
                          label: 'Statistics',
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(AppIcons.home),
                          activeIcon: SvgPicture.asset(AppIcons.homeFilled),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(AppIcons.settings),
                          activeIcon: SvgPicture.asset(AppIcons.settingsFilled),
                          label: 'Settings',
                        ),
                      ],
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
