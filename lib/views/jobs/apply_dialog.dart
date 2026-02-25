import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/applications_controller.dart';
import '../../models/offre_model.dart';

class ApplyDialog extends StatefulWidget {
  final Offre job;

  const ApplyDialog({super.key, required this.job});

  @override
  State<ApplyDialog> createState() => _ApplyDialogState();
}

class _ApplyDialogState extends State<ApplyDialog> {
  final _messageController = TextEditingController();
  bool _loading = false;
  bool _useCvUrl = true;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = context.read<AuthController>().user;
    if (user == null) return;
    setState(() => _loading = true);
    final ok = await context.read<ApplicationsController>().apply(
          jobId: widget.job.id,
          candidateId: user.id,
          recruiterId: widget.job.recruiterId,
          jobTitle: widget.job.title,
          cvUrl: _useCvUrl ? user.cvUrl : null,
          coverMessage: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
          candidateName: user.displayName,
          candidateEmail: user.email,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidature envoyée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ApplicationsController>().error ?? 'Erreur',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final hasCv = user?.cvUrl != null && user!.cvUrl!.isNotEmpty;

    return AlertDialog(
      title: const Text('Postuler'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.job.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (hasCv)
              CheckboxListTile(
                title: const Text('Utiliser mon CV du profil'),
                value: _useCvUrl,
                onChanged: (v) => setState(() => _useCvUrl = v ?? true),
                controlAffinity: ListTileControlAffinity.leading,
              )
            else
              const Text(
                'Ajoutez un CV dans votre profil pour l\'envoyer avec vos candidatures.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 8),
            const Text('Message de motivation (optionnel)'),
            const SizedBox(height: 4),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Présentez-vous et votre motivation...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Envoyer'),
        ),
      ],
    );
  }
}
