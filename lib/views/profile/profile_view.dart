import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/applications_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../models/candidature_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatelessWidget {
  final VoidCallback? openDrawer;

  const ProfileView({super.key, this.openDrawer});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.primary,
            ),
          ),
        ),
      );
    }

    final isCandidate = user.isCandidate;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: openDrawer != null
            ? IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: openDrawer,
              )
            : null,
        title: Text(
          'Mon profil',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          children: [
            if (isCandidate)
              _CandidateStats(userId: user.id)
            else
              _RecruiterStats(recruiterId: user.id),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppTheme.outline.withValues(alpha: 0.5)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            (user.displayName ?? user.email)
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    user.displayName ?? user.email,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.outline.withValues(alpha: 0.5)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  if (isCandidate) ...[
                    _Tile(
                        icon: Icons.phone_rounded,
                        label: 'Téléphone',
                        value: user.phone ?? '—'),
                    _divider(),
                    _Tile(
                        icon: Icons.work_rounded,
                        label: 'Domaine recherché',
                        value: user.domain ?? '—'),
                    _divider(),
                    _Tile(
                        icon: Icons.location_on_rounded,
                        label: 'Ville / Pays',
                        value: [user.city, user.country]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(', ')
                            .ifEmpty('—')),
                    _divider(),
                    _Tile(
                        icon: Icons.description_rounded,
                        label: 'CV',
                        value: user.cvUrl != null ? 'PDF joint' : '—'),
                    if (user.description != null &&
                        user.description!.isNotEmpty) ...[
                      _divider(),
                      _Tile(
                          icon: Icons.info_outline_rounded,
                          label: 'Description',
                          value: user.description!),
                    ],
                  ] else ...[
                    _Tile(
                        icon: Icons.business_rounded,
                        label: 'Entreprise',
                        value: user.companyName ?? '—'),
                    _divider(),
                    _Tile(
                        icon: Icons.phone_rounded,
                        label: 'Téléphone',
                        value: user.phone ?? '—'),
                    _divider(),
                    _Tile(
                        icon: Icons.category_rounded,
                        label: 'Secteur',
                        value: user.companySector ?? '—'),
                    if (user.companyDescription != null &&
                        user.companyDescription!.isNotEmpty) ...[
                      _divider(),
                      _Tile(
                          icon: Icons.description_rounded,
                          label: 'Description',
                          value: user.companyDescription!),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EditProfileView(),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded, size: 22),
                label: const Text('Modifier le profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: Icon(Icons.logout_rounded, size: 22,
                    color: Theme.of(context).colorScheme.error),
                label: Text(
                  'Déconnexion',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(height: 1, color: AppTheme.outline.withValues(alpha: 0.6)),
      );

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Déconnexion'),
        content: const Text(
            'Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Déconnexion',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<AuthController>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }
}

extension _Ext on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _CandidateStats extends StatelessWidget {
  final String userId;

  const _CandidateStats({required this.userId});

  @override
  Widget build(BuildContext context) {
    final applications =
        context.watch<ApplicationsController>().candidateApplications;
    final favoriteIds =
        context.watch<FavoritesController>().favoriteJobIds;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _StatChip(
                icon: Icons.send_rounded,
                label: 'Candidatures',
                value: '${applications.length}',
                color: AppTheme.primary,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatChip(
                icon: Icons.favorite_rounded,
                label: 'Favoris',
                value: '${favoriteIds.length}',
                color: Colors.red.shade400,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecruiterStats extends StatefulWidget {
  final String recruiterId;

  const _RecruiterStats({required this.recruiterId});

  @override
  State<_RecruiterStats> createState() => _RecruiterStatsState();
}

class _RecruiterStatsState extends State<_RecruiterStats> {
  int _offersCount = 0;
  int _totalCandidates = 0;
  int _accepted = 0;
  int _rejected = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await context
        .read<ApplicationsController>()
        .getRecruiterApplications(widget.recruiterId);
    final jobCount = await FirestoreService()
        .getJobCountByRecruiter(widget.recruiterId);
    if (!mounted) return;
    setState(() {
      _offersCount = jobCount;
      _totalCandidates = list.length;
      _accepted =
          list.where((c) => c.status == CandidatureStatus.accepted).length;
      _rejected =
          list.where((c) => c.status == CandidatureStatus.rejected).length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.primary,
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _StatChip(
                icon: Icons.work_rounded,
                label: 'Offres',
                value: '$_offersCount',
                color: AppTheme.primary,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatChip(
                icon: Icons.people_rounded,
                label: 'Candidats',
                value: '$_totalCandidates',
                color: AppTheme.accent,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _StatChip(
                icon: Icons.check_circle_rounded,
                label: 'Acceptés',
                value: '$_accepted',
                color: AppTheme.accent,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatChip(
                icon: Icons.cancel_rounded,
                label: 'Refusés',
                value: '$_rejected',
                color: Theme.of(context).colorScheme.error,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF334155),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
