import 'package:flutter/material.dart';
import '../jobs/recruiter_jobs_view.dart';
import '../applications/recruiter_applications_view.dart';
import '../jobs/external_jobs_view.dart';
import '../profile/profile_view.dart';

class RecruiterTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTab;
  final VoidCallback? openDrawer;

  const RecruiterTabs({
    super.key,
    required this.currentIndex,
    required this.onTab,
    this.openDrawer,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentIndex) {
      case 0:
        return RecruiterJobsView(openDrawer: openDrawer);
      case 1:
        return RecruiterApplicationsView(openDrawer: openDrawer);
      case 2:
        return ExternalJobsView(openDrawer: openDrawer);
      case 3:
        return ProfileView(openDrawer: openDrawer);
      default:
        return RecruiterJobsView(openDrawer: openDrawer);
    }
  }
}
