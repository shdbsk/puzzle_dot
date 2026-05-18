import 'package:flutter/material.dart';
import 'package:puzzle_dot/screens/widgets/app_drawer.dart';

class DrawerItemScreen extends StatelessWidget {
  final String title;

  const DrawerItemScreen({
    super.key,
    required this.title,
  });

  void _goHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

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
          label: '$title 페이지',
          child: Text(
            '$title 페이지',
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