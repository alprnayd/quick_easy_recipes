import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.restaurant_menu,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Quick & Easy Recipes',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Version 1.0.0',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          _buildInformationCard(
            context: context,
            title: 'Project Purpose',
            icon: Icons.info_outline,
            description:
            'Quick & Easy Recipes helps users discover, create, '
                'edit and organize simple recipes that can be prepared '
                'in a short amount of time.',
          ),
          const SizedBox(height: 12),

          _buildInformationCard(
            context: context,
            title: 'Main Features',
            icon: Icons.star_outline,
            description:
            '• Add, edit and delete recipes\n'
                '• Search recipes\n'
                '• Save favorite recipes\n'
                '• Browse recipes by category\n'
                '• Store data locally with SQLite',
          ),
          const SizedBox(height: 12),

          _buildInformationCard(
            context: context,
            title: 'Technologies',
            icon: Icons.code,
            description:
            '• Flutter and Dart\n'
                '• Material Design 3\n'
                '• go_router navigation\n'
                '• SQLite with sqflite\n'
                '• DAO and Repository structures',
          ),
          const SizedBox(height: 12),

          _buildInformationCard(
            context: context,
            title: 'Architecture',
            icon: Icons.account_tree_outlined,
            description:
            'The application follows a layered architecture:\n\n'
                'UI Layer → Business Layer → Repository → DAO → SQLite',
          ),
          const SizedBox(height: 12),

          _buildInformationCard(
            context: context,
            title: 'Developer',
            icon: Icons.person_outline,
            description: 'Developed by Alperen Aydın\nCEN306 Final Project',
          ),
          const SizedBox(height: 24),

          const Center(
            child: Text(
              'Made with Flutter',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Icon(icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}