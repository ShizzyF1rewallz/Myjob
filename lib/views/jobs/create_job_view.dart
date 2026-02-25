import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/jobs_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/offre_model.dart';

class CreateJobView extends StatefulWidget {
  const CreateJobView({super.key});

  @override
  State<CreateJobView> createState() => _CreateJobViewState();
}

class _CreateJobViewState extends State<CreateJobView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _skillsController = TextEditingController();
  ContractType _type = ContractType.cdi;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthController>().user;
    if (user == null || !user.isRecruiter) return;
    final ctrl = context.read<JobsController>();
    final id = await ctrl.createJob(
      recruiterId: user.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      type: _type,
      location: _locationController.text.trim(),
      salary: _salaryController.text.trim().isEmpty ? null : _salaryController.text.trim(),
      deadline: _deadline,
      skills: _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
    if (!mounted) return;
    if (id != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offre créée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ctrl.error ?? 'Erreur'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer une offre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du poste *',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ContractType>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type de contrat',
                  prefixIcon: Icon(Icons.badge),
                ),
                items: ContractType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(Offre.labelOf(t)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu *',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salaire (optionnel, \$)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Date limite'),
                subtitle: Text(
                  '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => _deadline = d);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skillsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Compétences requises (séparées par des virgules)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _submit(),
                child: const Text('Publier l\'offre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
