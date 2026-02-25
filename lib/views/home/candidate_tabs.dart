import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../jobs/job_list_view.dart';
import '../favorites/favorites_view.dart';
import '../applications/my_applications_view.dart';
import '../profile/profile_view.dart';

class CandidateTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTab;
  final VoidCallback? openDrawer;

  const CandidateTabs({
    super.key,
    required this.currentIndex,
    required this.onTab,
    this.openDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user!;
    switch (currentIndex) {
      case 0:
        return JobListView(openDrawer: openDrawer);
      case 1:
        return FavoritesView(userId: user.id, openDrawer: openDrawer);
      case 2:
        return MyApplicationsView(candidateId: user.id, openDrawer: openDrawer);
      case 3:
        return ProfileView(openDrawer: openDrawer);
      default:
        return JobListView(openDrawer: openDrawer);
    }
  }
}
