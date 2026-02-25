import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/jobs_controller.dart';
import '../../models/offre_model.dart';
import '../../utils/app_theme.dart';

class JobSearchSheet extends StatefulWidget {
  const JobSearchSheet({super.key});

  @override
  State<JobSearchSheet> createState() => _JobSearchSheetState();
}

class _JobSearchSheetState extends State<JobSearchSheet> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  String? _typeFilter;
  final _domainController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Rechercher / Filtrer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titre du poste',
                          prefixIcon: Icon(Icons.work_outline_rounded, size: 22),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Ville / Lieu',
                          prefixIcon: Icon(Icons.location_on_outlined, size: 22),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _typeFilter,
                        decoration: const InputDecoration(
                          labelText: 'Type de contrat',
                          prefixIcon: Icon(Icons.badge_outlined, size: 22),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Tous')),
                          ...ContractType.values.map((t) => DropdownMenuItem(
                                value: t.name,
                                child: Text(Offre.labelOf(t)),
                              )),
                        ],
                        onChanged: (v) => setState(() => _typeFilter = v),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _domainController,
                        decoration: const InputDecoration(
                          labelText: 'Domaine / Compétence',
                          prefixIcon: Icon(Icons.category_outlined, size: 22),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _titleController.clear();
                                _locationController.clear();
                                _domainController.clear();
                                setState(() => _typeFilter = null);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Réinitialiser'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<JobsController>().searchJobs(
                                      title: _titleController.text.trim().isEmpty
                                          ? null
                                          : _titleController.text.trim(),
                                      location: _locationController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _locationController.text.trim(),
                                      type: _typeFilter,
                                      domain: _domainController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _domainController.text.trim(),
                                    );
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Appliquer'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
