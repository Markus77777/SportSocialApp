import 'package:flutter/material.dart';
import 'run_homepage.dart';
import 'workout_homepage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigateToActivity(BuildContext context, String activity) {
    if (activity == '跑步') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RunHomePage()),
      );
    } else if (activity == '健身') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activities = [
      {'name': '跑步', 'icon': Icons.directions_run, 'color': Colors.deepOrange},
      {
        'name': '健身',
        'icon': Icons.fitness_center,
        'color': Colors.orangeAccent,
      },
    ];

  return Scaffold(
  body: Stack(
    children: [
      Column(
        children: [
          ClipPath(
            clipper: ArcClipper(),
            child: Container(
              color: Colors.deepOrange,
              height: 120,
              alignment: Alignment.center,
              child: SafeArea(
                child: Center(
                  child: Text(
                    '選擇運動主題',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return InkWell(
                    onTap: () => _navigateToActivity(context, activity['name']),
                    borderRadius: BorderRadius.circular(25),
                    splashColor: activity['color'].withOpacity(0.3),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            activity['color'].withOpacity(0.7),
                            activity['color'].withOpacity(0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: activity['color'].withOpacity(0.4),
                            offset: const Offset(0, 8),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 24,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              activity['icon'],
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            activity['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // 返回按鈕固定在左上角，永遠在畫面最上層
      Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    ],
  ),
);

  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
