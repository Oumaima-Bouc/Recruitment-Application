import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khedmni/screens/home_screen.dart';
import 'package:khedmni/screens/notification_screen.dart';
import 'package:khedmni/screens/profile_screen.dart';
import 'package:khedmni/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'package:khedmni/logic/cubits/notification_cubit.dart';
import 'package:khedmni/logic/cubits/notification_state.dart';
import 'package:khedmni/logic/cubits/auth_cubit.dart';
import 'package:khedmni/logic/cubits/auth_state.dart';
import 'package:khedmni/logic/cubits/job_cubit.dart';
import 'package:khedmni/logic/cubits/companies_cubit.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;


  final List<Widget> _screens = [
    const HomeScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load saved data if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      print('🏠 MainLayout initState - Auth state: ${authState.runtimeType}');
      if (authState is AuthAuthenticated) {
        print('👤 User already authenticated: ${authState.user.id}');
        print('📥 Loading saved jobs and followed companies...');
        context.read<JobCubit>().loadSavedJobs(authState.user.id);
        context.read<CompaniesCubit>().loadFollowedCompanies(authState.user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        print('🔔 MainLayout BlocListener - Auth state changed to: ${state.runtimeType}');
        if (state is AuthAuthenticated) {
          print('👤 User authenticated: ${state.user.id}');
          print('📥 Loading saved jobs and followed companies...');
          // Sync saved jobs data whenever user is verified/authenticated
          context.read<JobCubit>().loadSavedJobs(state.user.id);
          context.read<CompaniesCubit>().loadFollowedCompanies(state.user.id);
        }
      },
      child: PopScope(
        canPop: _selectedIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          setState(() {
            _selectedIndex = 0;
          });
        },
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primaryOrange,
            unselectedItemColor: Colors.grey,
            elevation: 8,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: AppLocalizations.of(context)!.home,
              ),
              BottomNavigationBarItem(
                icon: BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is NotificationLoaded) {
                      count = state.unreadCount;
                    }
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.notifications_outlined),
                    );
                  },
                ),
                activeIcon: BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is NotificationLoaded) {
                      count = state.unreadCount;
                    }
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.notifications),
                    );
                  },
                ),
                label: AppLocalizations.of(context)!.notifications,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: AppLocalizations.of(context)!.profileTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
