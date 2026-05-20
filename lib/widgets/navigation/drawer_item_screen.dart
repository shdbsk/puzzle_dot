import 'package:flutter/material.dart';
import 'package:puzzle_dot/widgets/navigation/app_drawer.dart';

class DrawerItemScreen extends StatelessWidget {
  final String title;

  const DrawerItemScreen({
    super.key,
    required this.title,
  });

  /// 홈 화면으로 이동
  ///
  /// Drawer 임시 페이지에서 메인 첫 화면으로 복귀
  void _goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// 상단 좌측 액션 영역
  ///
  /// 메뉴 열기와 홈 이동을 함께 제공
  Widget _buildLeading(BuildContext context) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Semantics(
              button: true,
              label: '메뉴 열기',
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            Semantics(
              button: true,
              label: '홈 화면으로 이동',
              child: IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () => _goHome(context),
              ),
            ),
          ],
        );
      },
    );
  }

  String get _bodyText {
    return '$title 페이지';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      drawer: AppDrawer(selectedTitle: title),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leadingWidth: 104,
        leading: _buildLeading(context),
      ),
      body: Center(
        child: Semantics(
          label: _bodyText,
          child: Text(
            _bodyText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }
}