import 'package:flutter/material.dart';
import 'package:puzzle_dot/models/drawer_menu_item.dart';
import 'package:puzzle_dot/screens/home/home_screen.dart';
import 'package:puzzle_dot/widgets/navigation/drawer_item_screen.dart';

const List<DrawerMenuItem> drawerMenuItems = [
  DrawerMenuItem(
    title: '점자 가이드',
    icon: Icons.menu_book_outlined,
    action: DrawerMenuAction.placeholder,
  ),
  DrawerMenuItem(
    title: '채팅',
    icon: Icons.chat_bubble_outline,
    action: DrawerMenuAction.chat,
  ),
  DrawerMenuItem(
    title: '설정',
    icon: Icons.settings_outlined,
    action: DrawerMenuAction.settings,
  ),
  DrawerMenuItem(
    title: 'Support',
    icon: Icons.support_agent_outlined,
    action: DrawerMenuAction.placeholder,
  ),
];

class AppDrawer extends StatelessWidget {
  final String? selectedTitle;

  const AppDrawer({
    super.key,
    this.selectedTitle,
  });

  /// Drawer 메뉴 선택 처리
  ///
  /// 메뉴 action에 따라 네브바 탭 또는 임시 페이지로 이동
  /// title 문자열 비교를 사용하지 않음
  void _selectItem(BuildContext context, DrawerMenuItem item) {
    Navigator.pop(context);

    switch (item.action) {
      case DrawerMenuAction.chat:
        _openMainTab(context, 2);
        return;

      case DrawerMenuAction.settings:
        _openMainTab(context, 3);
        return;

      case DrawerMenuAction.placeholder:
        _openPlaceholderPage(context, item.title);
        return;
    }
  }

  /// 메인 네비게이션 특정 탭으로 이동
  ///
  /// Chat / Settings는 하단 네비게이션 화면을 그대로 사용
  void _openMainTab(BuildContext context, int initialIndex) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(initialIndex: initialIndex),
      ),
      (route) => false,
    );
  }

  /// 아직 실제 화면이 없는 Drawer 항목 임시 페이지
  ///
  /// 점자 가이드 / Support는 추후 실제 화면 연결 가능
  void _openPlaceholderPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DrawerItemScreen(title: title),
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
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0F172A),
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
                  return _buildMenuTile(
                    context,
                    drawerMenuItems[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}