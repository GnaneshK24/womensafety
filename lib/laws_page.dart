import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LawsPage extends StatelessWidget {
  // Function to open the reference link
  void _launchURL() async {
    const url = 'https://wcd.gov.in/'; // Official Ministry of Women and Child Development link
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.lawsTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLawCard(
            context,
            localizations.domesticViolenceAct,
            localizations.domesticViolenceDesc,
          ),
          _buildLawCard(
            context,
            localizations.workplaceHarassmentAct,
            localizations.workplaceHarassmentDesc,
          ),
          _buildLawCard(
            context,
            localizations.dowryAct,
            localizations.dowryDesc,
          ),
          _buildLawCard(
            context,
            localizations.maternityAct,
            localizations.maternityDesc,
          ),
          _buildLawCard(
            context,
            localizations.childMarriageAct,
            localizations.childMarriageDesc,
          ),
          _buildLawCard(
            context,
            localizations.ipcSections,
            localizations.ipcDesc,
          ),
          _buildLawCard(
            context,
            localizations.mtpAct,
            localizations.mtpDesc,
          ),
          _buildLawCard(
            context,
            localizations.hinduSuccessionAct,
            localizations.hinduSuccessionDesc,
          ),
          _buildLawCard(
            context,
            localizations.indecentRepresentationAct,
            localizations.indecentRepresentationDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildLawCard(BuildContext context, String title, String description) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _launchURL,
                icon: const Icon(Icons.info_outline),
                label: Text(localizations.learnMore),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(200, 48),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
