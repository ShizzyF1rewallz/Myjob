import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/jobs_controller.dart';
import '../../models/offre_model.dart';
import '../../services/jobs_api_service.dart';

class ExternalJobsView extends StatefulWidget {
  final VoidCallback? openDrawer;

  const ExternalJobsView({super.key, this.openDrawer});

  @override
  State<ExternalJobsView> createState() => _ExternalJobsViewState();
}

class _ExternalJobsViewState extends State<ExternalJobsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsController>().fetchExternalJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.openDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: widget.openDrawer,
              )
            : null,
        title: const Text('Offres API externe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<JobsController>().fetchExternalJobs();
            },
          ),
        ],
      ),
      body: Consumer<JobsController>(
        builder: (_, ctrl, __) {
          if (ctrl.loading && ctrl.externalJobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.externalJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune offre importée',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => ctrl.fetchExternalJobs(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Charger les offres'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ctrl.externalJobs.length,
            itemBuilder: (_, i) {
              final dto = ctrl.externalJobs[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    dto.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${Offre.labelOf(dto.type)} • ${dto.location}'),
                      if (dto.companyName != null) Text(dto.companyName!),
                    ],
                  ),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () => _importJob(context, dto),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _importJob(BuildContext context, OffreDto dto) async {
    final user = context.read<AuthController>().user;
    if (user == null || !user.isRecruiter) return;
    final ctrl = context.read<JobsController>();
    final id = await ctrl.importExternalJob(user.id, dto);
    if (!context.mounted) return;
    if (id != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offre importée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ctrl.error ?? 'Erreur'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
