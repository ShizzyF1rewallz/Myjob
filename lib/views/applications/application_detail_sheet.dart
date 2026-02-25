import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/applications_controller.dart';
import '../../models/candidature_model.dart';
import '../chat/chat_view.dart';

class ApplicationDetailSheet extends StatelessWidget {
  final Candidature candidature;
  final VoidCallback onUpdated;

  const ApplicationDetailSheet({
    super.key,
    required this.candidature,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                candidature.jobTitle ?? 'Candidature',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Candidat: ${candidature.candidateName ?? '—'}'),
              Text('Email: ${candidature.candidateEmail ?? '—'}'),
              Text('Date: ${DateFormat.yMd().format(candidature.createdAt)}'),
              Text('Statut: ${candidature.statusLabel}'),
              if (candidature.coverMessage != null &&
                  candidature.coverMessage!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Message de motivation:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(candidature.coverMessage!),
              ],
              if (candidature.cvUrl != null && candidature.cvUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Ouvrir l'URL du CV (launchUrl)
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Voir le CV'),
                ),
              ],
              const SizedBox(height: 24),
              if (candidature.status == CandidatureStatus.pending) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => _updateStatus(
                          context,
                          CandidatureStatus.accepted,
                        ),
                        child: const Text('Accepter'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => _updateStatus(
                          context,
                          CandidatureStatus.rejected,
                        ),
                        child: const Text('Refuser'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (candidature.status == CandidatureStatus.accepted) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatView(
                            candidature: candidature,
                            isRecruiter: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_rounded, size: 20),
                    label: const Text('Discuter avec le candidat'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Supprimer la candidature'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    CandidatureStatus status,
  ) async {
    final ok = await context
        .read<ApplicationsController>()
        .updateStatus(candidature.id, status);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Candidature ${status.name}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
      onUpdated();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la candidature ?'),
        content: const Text(
          'Cette action est irréversible.',
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
    final ok =
        await context.read<ApplicationsController>().deleteApplication(candidature.id);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidature supprimée')),
      );
      Navigator.of(context).pop();
      onUpdated();
    }
  }
}
