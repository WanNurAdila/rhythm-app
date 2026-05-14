import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Home',
    'Beats',
    'Add',
    'Streak',
    'Profile',
  ];

  static const List<IconData> _icons = [
    Icons.home,
    Icons.calendar_today,
    Icons.add,
    Icons.local_fire_department,
    Icons.person,
  ];

  static const List<String> _labels = [
    'Home',
    'Beats',
    '',
    'Streak',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sign out',
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(16),
          child: SizedBox(height: 16),
        ),
      ),
      body: Center(
        child: Text(
          'You are logged in. Permission granted. Welcome to ${_titles[_selectedIndex]} screen.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: Container(
        height: 104,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final isSelected = _selectedIndex == index;
            final isAddIcon = index == 2;
            final iconColor = isSelected || isAddIcon
                ? Theme.of(context).colorScheme.primary
                : Colors.grey;
            final baseIconSize = isAddIcon ? 40.0 : 28.0;
            final iconSize = isSelected && !isAddIcon ? baseIconSize + 6 : baseIconSize;
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _icons[index],
                      color: iconColor,
                      size: iconSize,
                    ),
                    const SizedBox(height: 4),
                    if (isSelected && !isAddIcon)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                    else if (_labels[index].isNotEmpty)
                      Text(
                        _labels[index],
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    context.go('/login');
  }
}
