import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/applications_controller.dart';
import '../../models/candidature_model.dart';
import 'application_detail_sheet.dart';

class RecruiterApplicationsView extends StatefulWidget {
  final VoidCallback? openDrawer;

  const RecruiterApplicationsView({super.key, this.openDrawer});

  @override
  State<RecruiterApplicationsView> createState() =>
      _RecruiterApplicationsViewState();
}

class _RecruiterApplicationsViewState extends State<RecruiterApplicationsView> {
  List<Candidature> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthController>().user;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final list =
        await context.read<ApplicationsController>().getRecruiterApplications(user.id);
    if (mounted) {
      setState(() {
        _list = list;
        _loading = false;
      });
    }
  }

  Color _statusColor(CandidatureStatus s) {
    switch (s) {
      case CandidatureStatus.pending:
        return Colors.orange;
      case CandidatureStatus.accepted:
        return Colors.green;
      case CandidatureStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: widget.openDrawer != null
              ? IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: widget.openDrawer,
                )
              : null,
          title: const Text('Candidatures reçues'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_list.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: widget.openDrawer != null
              ? IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: widget.openDrawer,
                )
              : null,
          title: const Text('Candidatures reçues'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Aucune candidature pour le moment',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: widget.openDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: widget.openDrawer,
              )
            : null,
        title: const Text('Candidatures reçues'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _list.length,
          itemBuilder: (_, i) {
            final app = _list[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  app.jobTitle ?? 'Offre',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('${app.candidateName ?? 'Candidat'} • ${app.candidateEmail ?? ''}'),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(
                        app.statusLabel,
                        style: TextStyle(
                          color: _statusColor(app.status),
                          fontSize: 12,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      backgroundColor: _statusColor(app.status).withOpacity(0.2),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ApplicationDetailSheet(
                      candidature: app,
                      onUpdated: _load,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
