import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/jobs_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/applications_controller.dart';
import '../../models/offre_model.dart';
import '../../utils/app_theme.dart';
import 'apply_dialog.dart';

class JobDetailView extends StatefulWidget {
  final String jobId;

  const JobDetailView({super.key, required this.jobId});

  @override
  State<JobDetailView> createState() => _JobDetailViewState();
}

class _JobDetailViewState extends State<JobDetailView> {
  Offre? _job;
  bool _loading = true;
  bool? _isFavorite;
  bool? _hasApplied;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final job = await context.read<JobsController>().getJob(widget.jobId);
    final user = context.read<AuthController>().user;
    if (user != null) {
      final fav = context.read<FavoritesController>();
      final isFav = fav.isFavorite(widget.jobId);
      final appCtrl = context.read<ApplicationsController>();
      final applied = await appCtrl.hasApplied(user.id, widget.jobId);
      if (mounted) {
        setState(() {
          _job = job;
          _loading = false;
          _isFavorite = isFav;
          _hasApplied = applied;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _job = job;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }
    if (_job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 56, color: AppTheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'Offre introuvable',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }
    final job = _job!;
    final user = context.watch<AuthController>().user;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          'Détail de l\'offre',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          if (user != null && user.isCandidate)
            IconButton(
              icon: Icon(
                _isFavorite == true
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isFavorite == true ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.outline.withValues(alpha: 0.6)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _ChipDetail(
                          icon: Icons.work_rounded,
                          label: job.typeLabel,
                          color: AppTheme.primary),
                      _ChipDetail(
                          icon: Icons.location_on_rounded,
                          label: job.location,
                          color: AppTheme.onSurfaceVariant),
                      if (job.companyName != null)
                        _ChipDetail(
                            icon: Icons.business_rounded,
                            label: job.companyName!,
                            color: AppTheme.onSurfaceVariant),
                    ],
                  ),
                  if (job.salary != null && job.salary!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.attach_money_rounded,
                            size: 20, color: AppTheme.accent),
                        const SizedBox(width: 6),
                        Text(
                          job.salary!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Date limite : ${DateFormat.yMd().format(job.deadline)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (job.skills.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Compétences requises',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skills
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.outline.withValues(alpha: 0.5)),
              ),
              child: Text(
                job.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: const Color(0xFF475569),
                    ),
              ),
            ),
            if (job.externalUrl != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                label: const Text('Voir l\'offre originale'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (user != null && user.isCandidate && !job.fromExternalApi) ...[
              if (_hasApplied == true)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppTheme.accent, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Vous avez déjà postulé à cette offre',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: const Color(0xFF065F46),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _openApply(context, job),
                    icon: const Icon(Icons.send_rounded, size: 22),
                    label: const Text('Postuler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final user = context.read<AuthController>().user;
    if (user == null) return;
    await context
        .read<FavoritesController>()
        .toggleFavorite(user.id, widget.jobId);
    setState(() => _isFavorite =
        context.read<FavoritesController>().isFavorite(widget.jobId));
  }

  void _openApply(BuildContext context, Offre job) {
    showDialog(
      context: context,
      builder: (_) => ApplyDialog(job: job),
    ).then((_) => _load());
  }
}

class _ChipDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChipDetail(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
