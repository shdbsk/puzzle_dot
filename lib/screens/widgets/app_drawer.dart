import 'package:flutter/material.dart';
import 'package:puzzle_dot/screens/home_screen.dart';
import 'package:puzzle_dot/screens/widgets/drawer_item_screen.dart';

class DrawerMenuItem {
  final String title;
  final IconData icon;

  const DrawerMenuItem({
    required this.title,
    required this.icon,
  });
}

const drawerMenuItems = [
  DrawerMenuItem(
    title: '점자 가이드',
    icon: Icons.menu_book_outlined,
  ),
  DrawerMenuItem(
    title: '채팅',
    icon: Icons.chat_bubble_outline,
  ),
  DrawerMenuItem(
    title: '설정',
    icon: Icons.settings_outlined,
  ),
  DrawerMenuItem(
    title: 'Support',
    icon: Icons.support_agent_outlined,
  ),
];

class AppDrawer extends StatelessWidget {
  final String? selectedTitle;

  const AppDrawer({
    super.key,
    this.selectedTitle,
  });

  void _selectItem(BuildContext context, DrawerMenuItem item) {
    Navigator.pop(context);

    if (item.title == '채팅') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 2),
        ),
        (route) => false,
      );
      return;
    }

    if (item.title == '설정') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 3),
        ),
        (route) => false,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DrawerItemScreen(title: item.title),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, DrawerMenuItem item) {
    final isSelected = item.title == selectedTitle;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${item.title} 메뉴',
      child: Material(
        color: isSelected ? const Color(0xFF1D4ED8) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _selectItem(context, item),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
              color: Colors.white,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PuzzleDot',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '메뉴',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                itemCount: drawerMenuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  return _buildMenuTile(context, drawerMenuItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}