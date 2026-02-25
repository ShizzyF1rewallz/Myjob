import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/jobs_controller.dart';
import '../../models/offre_model.dart';
import 'job_detail_view.dart';
import 'create_job_view.dart';
import 'edit_job_view.dart';

class RecruiterJobsView extends StatefulWidget {
  final VoidCallback? openDrawer;

  const RecruiterJobsView({super.key, this.openDrawer});

  @override
  State<RecruiterJobsView> createState() => _RecruiterJobsViewState();
}

class _RecruiterJobsViewState extends State<RecruiterJobsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().user;
      if (user != null) {
        context.read<JobsController>().loadRecruiterJobs(user.id);
      }
    });
  }

  Future<void> _confirmDelete(BuildContext context, Offre job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'offre ?'),
        content: Text(
          'Supprimer définitivement "${job.title}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final ok = await context.read<JobsController>().deleteJob(job.id);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offre supprimée'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<JobsController>().error ?? 'Erreur',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        title: const Text('Mes offres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CreateJobView(),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<JobsController>(
        builder: (_, ctrl, __) {
          if (ctrl.loading && ctrl.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune offre publiée',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateJobView(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une offre'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ctrl.jobs.length,
            itemBuilder: (_, i) {
              final job = ctrl.jobs[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    job.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${job.typeLabel} • ${job.location}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditJobView(job: job),
                          ),
                        );
                      } else if (v == 'delete') {
                        await _confirmDelete(context, job);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Modifier'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JobDetailView(jobId: job.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CreateJobView(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
