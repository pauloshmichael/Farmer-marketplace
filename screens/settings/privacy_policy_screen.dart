import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Last updated: January 1, 2024',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              '1. Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, update your profile, place an order, or communicate with us. This may include:\n\n'
                  '• Name and contact information (email, phone number, address)\n'
                  '• Account credentials (password, authentication data)\n'
                  '• Payment information (credit card details, billing address)\n'
                  '• Order history and preferences\n'
                  '• Communications with us and other users\n'
                  '• Location data (with your consent)',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n'
                  '• Process and fulfill your orders\n'
                  '• Communicate with you about your orders and account\n'
                  '• Provide customer support\n'
                  '• Improve our products and services\n'
                  '• Send you promotional offers and updates (with your consent)\n'
                  '• Prevent fraud and ensure security',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '3. Information Sharing',
              'We do not sell your personal information. We may share your information in the following circumstances:\n\n'
                  '• With farmers and sellers to fulfill your orders\n'
                  '• With service providers who assist our operations\n'
                  '• To comply with legal obligations\n'
                  '• To protect our rights and safety',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '4. Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes encryption, secure servers, and regular security assessments.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '5. Your Rights',
              'Depending on your location, you may have the right to:\n\n'
                  '• Access your personal information\n'
                  '• Correct inaccurate information\n'
                  '• Delete your information\n'
                  '• Object to certain processing\n'
                  '• Data portability\n'
                  '• Withdraw consent',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '6. Cookies and Tracking',
              'We use cookies and similar technologies to enhance your experience, analyze usage, and personalize content. You can control cookie preferences through your browser settings.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '7. Children\'s Privacy',
              'Our services are not intended for children under 13. We do not knowingly collect information from children under 13.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '8. Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '9. Contact Us',
              'If you have questions about this privacy policy, please contact us at:\n\n'
                  'Email: privacy@farmermarketplace.com\n'
                  'Phone: +1-800-123-4567\n'
                  'Address: 123 Farmer Street, Agricultural City, AC 12345',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
