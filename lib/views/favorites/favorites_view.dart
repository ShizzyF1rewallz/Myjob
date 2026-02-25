import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/jobs_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../models/offre_model.dart';
import '../../utils/app_theme.dart';
import '../jobs/job_detail_view.dart';

class FavoritesView extends StatefulWidget {
  final String userId;
  final VoidCallback? openDrawer;

  const FavoritesView({super.key, required this.userId, this.openDrawer});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsController>().loadAllJobs();
      context.read<FavoritesController>().listenFavorites(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final favCtrl = context.watch<FavoritesController>();
    final ids = favCtrl.favoriteJobIds;
    if (ids.isEmpty) {
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
            'Offres sauvegardées',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: 56,
                    color: Colors.red.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucune offre en favori',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Ajoutez des offres avec le cœur sur leur détail.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
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
          'Offres sauvegardées',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: FutureBuilder(
        future: context.read<JobsController>().getJobsByIds(ids),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primary,
                ),
              ),
            );
          }
          final favoriteJobs = snap.data!;
          if (favoriteJobs.isEmpty) {
            return Center(
              child: Text(
                'Offres supprimées ou introuvables',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            itemCount: favoriteJobs.length,
            itemBuilder: (_, i) {
              final job = favoriteJobs[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _FavoriteJobCard(
                  job: job,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JobDetailView(jobId: job.id),
                    ),
                  ),
                  onRemove: () async {
                    await favCtrl.removeFavorite(widget.userId, job.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Retiré des favoris'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteJobCard extends StatelessWidget {
  final Offre job;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteJobCard({
    required this.job,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 24,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.typeLabel} • ${job.location}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.onSurfaceVariant,
                ),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
