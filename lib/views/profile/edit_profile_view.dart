import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _domainController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _descController;
  late TextEditingController _companyNameController;
  late TextEditingController _companyDescController;
  late TextEditingController _companySectorController;
  List<String> _skills = [];
  final _skillInputController = TextEditingController();
  bool _loading = false;
  String? _photoPath;
  String? _cvPath;
  String? _companyLogoPath;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthController>().user!;
    _nameController = TextEditingController(text: u.displayName);
    _phoneController = TextEditingController(text: u.phone);
    _domainController = TextEditingController(text: u.domain);
    _cityController = TextEditingController(text: u.city);
    _countryController = TextEditingController(text: u.country);
    _descController = TextEditingController(text: u.description);
    _companyNameController = TextEditingController(text: u.companyName);
    _companyDescController = TextEditingController(text: u.companyDescription);
    _companySectorController = TextEditingController(text: u.companySector);
    _skills = List.from(u.skills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _domainController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _descController.dispose();
    _companyNameController.dispose();
    _companyDescController.dispose();
    _companySectorController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCompanyLogo) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    setState(() {
      if (isCompanyLogo) {
        _companyLogoPath = x.path;
      } else {
        _photoPath = x.path;
      }
    });
  }

  Future<void> _pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _cvPath = result.files.single.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final u = auth.user!;
    setState(() => _loading = true);

    String? photoUrl = u.photoUrl;
    String? cvUrl = u.cvUrl;
    String? companyLogoUrl = u.companyLogoUrl;
    final storage = StorageService();

    try {
      if (_photoPath != null) {
        photoUrl = await storage.uploadPhoto(u.id, File(_photoPath!));
      }
      if (_cvPath != null) {
        cvUrl = await storage.uploadCv(u.id, File(_cvPath!));
      }
      if (_companyLogoPath != null && u.isRecruiter) {
        companyLogoUrl =
            await storage.uploadCompanyLogo(u.id, File(_companyLogoPath!));
      }
    } catch (_) {}

    final updated = u.copyWith(
      displayName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      domain: _domainController.text.trim().isEmpty
          ? null
          : _domainController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      skills: _skills,
      photoUrl: photoUrl,
      cvUrl: cvUrl,
      companyName: _companyNameController.text.trim().isEmpty
          ? null
          : _companyNameController.text.trim(),
      companyDescription: _companyDescController.text.trim().isEmpty
          ? null
          : _companyDescController.text.trim(),
      companySector: _companySectorController.text.trim().isEmpty
          ? null
          : _companySectorController.text.trim(),
      companyLogoUrl: companyLogoUrl,
    );

    final ok = await auth.updateProfile(updated);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil enregistré'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user!;
    final isCandidate = user.isCandidate;

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(false),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.primary.withOpacity(0.2),
                    backgroundImage: _photoPath != null
                        ? FileImage(File(_photoPath!))
                        : (user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null),
                    child: _photoPath == null && user.photoUrl == null
                        ? const Icon(Icons.add_a_photo, size: 40)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              if (isCandidate) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _domainController,
                  decoration: const InputDecoration(
                    labelText: 'Domaine recherché',
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Pays',
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Compétences (ajoutez puis validez)'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _skillInputController,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Flutter, Firebase',
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            setState(() {
                              _skills.add(v.trim());
                              _skillInputController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final v = _skillInputController.text.trim();
                        if (v.isNotEmpty) {
                          setState(() {
                            _skills.add(v);
                            _skillInputController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  children: _skills
                      .map((s) => Chip(
                            label: Text(s),
                            onDeleted: () =>
                                setState(() => _skills.remove(s)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('CV (PDF ou texte)'),
                  subtitle: Text(_cvPath ?? (user.cvUrl != null ? 'Fichier actuel' : 'Aucun')),
                  trailing: TextButton(
                    onPressed: _pickCv,
                    child: const Text('Choisir'),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description personnelle',
                    alignLabelWithHint: true,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'entreprise',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: ListTile(
                    title: const Text('Logo entreprise'),
                    subtitle: Text(
                      _companyLogoPath != null
                          ? 'Nouvelle image choisie'
                          : (user.companyLogoUrl != null ? 'Logo actuel' : 'Aucun'),
                    ),
                    trailing: const Icon(Icons.upload),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _companyDescController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description de l\'entreprise',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _companySectorController,
                  decoration: const InputDecoration(
                    labelText: 'Secteur d\'activité',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
