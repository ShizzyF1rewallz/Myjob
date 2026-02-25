import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/jobs_controller.dart';
import '../../models/offre_model.dart';

class EditJobView extends StatefulWidget {
  final Offre job;

  const EditJobView({super.key, required this.job});

  @override
  State<EditJobView> createState() => _EditJobViewState();
}

class _EditJobViewState extends State<EditJobView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _salaryController;
  late TextEditingController _skillsController;
  late ContractType _type;
  late DateTime _deadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _descController = TextEditingController(text: widget.job.description);
    _locationController = TextEditingController(text: widget.job.location);
    _salaryController = TextEditingController(text: widget.job.salary ?? '');
    _skillsController = TextEditingController(
      text: widget.job.skills.join(', '),
    );
    _type = widget.job.type;
    _deadline = widget.job.deadline;
  }

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
    final updated = widget.job.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      type: _type,
      location: _locationController.text.trim(),
      salary: _salaryController.text.trim().isEmpty
          ? null
          : _salaryController.text.trim(),
      deadline: _deadline,
      skills: _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
    final ok = await context.read<JobsController>().updateJob(updated);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offre mise à jour'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('Modifier l\'offre')),
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
                onPressed: _submit,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
