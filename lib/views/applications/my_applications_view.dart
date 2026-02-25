import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/applications_controller.dart';
import '../../models/candidature_model.dart';
import '../../utils/app_theme.dart';
import '../jobs/job_detail_view.dart';
import '../chat/chat_view.dart';

class MyApplicationsView extends StatefulWidget {
  final String candidateId;
  final VoidCallback? openDrawer;

  const MyApplicationsView({super.key, required this.candidateId, this.openDrawer});

  @override
  State<MyApplicationsView> createState() => _MyApplicationsViewState();
}

class _MyApplicationsViewState extends State<MyApplicationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ApplicationsController>()
          .listenCandidateApplications(widget.candidateId);
    });
  }

  Color _statusColor(CandidatureStatus s) {
    switch (s) {
      case CandidatureStatus.pending:
        return Colors.orange.shade700;
      case CandidatureStatus.accepted:
        return AppTheme.accent;
      case CandidatureStatus.rejected:
        return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list =
        context.watch<ApplicationsController>().candidateApplications;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: widget.openDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: widget.openDrawer,
              )
            : null,
        title: Text(
          'Mes candidatures',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: list.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 56,
                        color: AppTheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Aucune candidature',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Postulez à des offres depuis la liste pour les retrouver ici.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final app = list[i];
                final statusColor = _statusColor(app.status);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => JobDetailView(jobId: app.jobId),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.outline.withValues(alpha: 0.6)),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.send_rounded,
                                size: 24,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.jobTitle ?? 'Offre',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Postulé le ${DateFormat.yMd().format(app.createdAt)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      app.statusLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (app.status == CandidatureStatus.accepted) ...[
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatView(
                                        candidature: app,
                                        isRecruiter: false,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_rounded),
                                color: AppTheme.primary,
                                tooltip: 'Discuter avec le recruteur',
                              ),
                            ],
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
