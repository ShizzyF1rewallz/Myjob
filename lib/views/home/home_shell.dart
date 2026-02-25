import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/applications_controller.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import 'candidate_tabs.dart';
import 'recruiter_tabs.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().user;
      if (user != null) {
        context.read<FavoritesController>().listenFavorites(user.id);
        if (user.isCandidate) {
          context
              .read<ApplicationsController>()
              .listenCandidateApplications(user.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) return const SizedBox.shrink();
    return Scaffold(
      drawer: _AppDrawer(
        user: user,
        currentIndex: _index,
        isCandidate: user.isCandidate,
        onTab: (i) {
          setState(() => _index = i);
          Navigator.of(context).pop();
        },
      ),
      body: Builder(
        builder: (ctx) {
          final openDrawer = () => Scaffold.of(ctx).openDrawer();
          return user.isCandidate
              ? CandidateTabs(
                  currentIndex: _index,
                  onTab: (i) => setState(() => _index = i),
                  openDrawer: openDrawer,
                )
              : RecruiterTabs(
                  currentIndex: _index,
                  onTab: (i) => setState(() => _index = i),
                  openDrawer: openDrawer,
                );
        },
      ),
      bottomNavigationBar: user.isCandidate
          ? _buildNav(context, _candidateItems, _index, setState)
          : _buildNav(context, _recruiterItems, _index, setState),
    );
  }

  static final _candidateItems = [
    (icon: Icons.work_outline_rounded, active: Icons.work_rounded, label: 'Offres'),
    (icon: Icons.favorite_border_rounded, active: Icons.favorite_rounded, label: 'Favoris'),
    (icon: Icons.send_outlined, active: Icons.send_rounded, label: 'Candidatures'),
    (icon: Icons.person_outline_rounded, active: Icons.person_rounded, label: 'Profil'),
  ];

  static final _recruiterItems = [
    (icon: Icons.work_outline_rounded, active: Icons.work_rounded, label: 'Mes offres'),
    (icon: Icons.people_outline_rounded, active: Icons.people_rounded, label: 'Candidatures'),
    (icon: Icons.cloud_download_outlined, active: Icons.cloud_download_rounded, label: 'API'),
    (icon: Icons.person_outline_rounded, active: Icons.person_rounded, label: 'Profil'),
  ];

  Widget _buildNav(
    BuildContext context,
    List<({IconData icon, IconData active, String label})> items,
    int index,
    void Function(void Function()) setState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = index == i;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? item.active : item.icon,
                            size: 26,
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final AppUser user;
  final int currentIndex;
  final bool isCandidate;
  final ValueChanged<int> onTab;

  const _AppDrawer({
    required this.user,
    required this.currentIndex,
    required this.isCandidate,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    final profileIndex = isCandidate ? 3 : 3;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary,
                    AppTheme.primaryDark,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      (user.displayName ?? user.email).isNotEmpty
                          ? (user.displayName ?? user.email).substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.displayName ?? 'Mon compte',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded, color: AppTheme.onSurfaceVariant),
              title: const Text('Profil'),
              onTap: () {
                onTab(profileIndex);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded, color: AppTheme.onSurfaceVariant),
              title: const Text('FAQ'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/faq');
              },
            ),
            const Divider(height: 24),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Déconnexion',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await context.read<AuthController>().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
