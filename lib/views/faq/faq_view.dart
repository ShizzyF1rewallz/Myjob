import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// Page FAQ : questions fréquentes sur la plateforme MyJob.
class FaqView extends StatelessWidget {
  const FaqView({super.key});

  static const _items = [
    (
      question: 'Comment créer un compte ?',
      answer: 'Sur l\'écran d\'accueil, cliquez sur « S\'inscrire ». Choisissez Candidat ou Recruteur, renseignez votre email et un mot de passe (6 caractères minimum), puis validez. Vous êtes ensuite connecté automatiquement.',
    ),
    (
      question: 'J\'ai oublié mon mot de passe.',
      answer: 'Sur la page de connexion, cliquez sur « Mot de passe oublié ? ». Entrez votre email : un lien de réinitialisation vous sera envoyé par Firebase.',
    ),
    (
      question: 'Comment postuler à une offre ?',
      answer: 'Connectez-vous en tant que Candidat. Parcourez les offres, ouvrez celle qui vous intéresse et cliquez sur « Postuler ». Vous pouvez joindre un CV et un message. Vos candidatures sont visibles dans l\'onglet « Candidatures ».',
    ),
    (
      question: 'Comment publier une offre en tant que recruteur ?',
      answer: 'Inscrivez-vous ou connectez-vous en tant que Recruteur. Allez dans « Mes offres » puis créez une nouvelle offre (titre, lieu, type de contrat, salaire, description, etc.). Vous pourrez modifier ou supprimer vos offres depuis cette même section.',
    ),
    (
      question: 'Où voir les candidatures reçues ?',
      answer: 'En tant que Recruteur, ouvrez l\'onglet « Candidatures » dans la barre de navigation. Vous y voyez toutes les candidatures pour vos offres et pouvez les accepter, refuser ou supprimer.',
    ),
    (
      question: 'Comment sauvegarder des offres en favoris ?',
      answer: 'Sur une offre, cliquez sur l\'icône cœur pour l\'ajouter aux favoris. Retrouvez-les dans l\'onglet « Favoris » (candidats uniquement).',
    ),
    (
      question: 'D\'où viennent les offres « API » ?',
      answer: 'L\'onglet « API » (recruteurs) ou les offres externes permettent d\'importer des annonces depuis l\'API Arbeitnow. Ces offres peuvent être synchronisées avec votre base pour élargir le catalogue.',
    ),
    (
      question: 'Mes données sont-elles sécurisées ?',
      answer: 'L\'authentification et les données sont gérées par Firebase (Google). Les mots de passe sont chiffrés. Ne partagez jamais vos identifiants.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('FAQ'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final item = _items[i];
          return _FaqTile(
            question: item.question,
            answer: item.answer,
          );
        },
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.onSurfaceVariant,
                    size: 28,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
