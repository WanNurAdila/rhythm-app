import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:toastification/toastification.dart';

import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_state.dart';
import '../services/task_service.dart';
import 'add_task_sheet.dart';
import 'beats_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'streak_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  TaskBloc? _taskBloc;

  static const List<String> _titles = [
    'Home',
    'Beats',
    'Add',
    'Streak',
    'Profile',
  ];

  static final List<Widget> _pages = [
    const HomePage(),
    const BeatsPage(),
    const SizedBox.shrink(),
    const StreakPage(),
    const ProfilePage(),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_taskBloc == null) {
      final client = GraphQLProvider.of(context).value;
      _taskBloc = TaskBloc(taskService: TaskService(client: client));
    }
  }

  @override
  void dispose() {
    _taskBloc?.close();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      AddTaskSheet.show(context, taskBloc: _taskBloc!);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _taskBloc!,
      child: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: const Text('Something went wrong'),
              description: Text(state.message),
              autoCloseDuration: const Duration(seconds: 6),
              alignment: Alignment.bottomCenter,
              showProgressBar: false,
            );
          }
        },
        child: Scaffold(
          appBar: _selectedIndex == 4
              ? null
              : AppBar(
                  title: Text(_titles[_selectedIndex]),
                  bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(16),
                    child: SizedBox(height: 16),
                  ),
                ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: Container(
            height: 104,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_icons.length, (index) {
                final isSelected = _selectedIndex == index;
                final isAddIcon = index == 2;
                final iconColor = isSelected || isAddIcon
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey;
                final baseIconSize = isAddIcon ? 40.0 : 28.0;
                final iconSize = isSelected && !isAddIcon
                    ? baseIconSize + 6
                    : baseIconSize;

                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_icons[index], color: iconColor, size: iconSize),
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
                            style: TextStyle(color: iconColor, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
