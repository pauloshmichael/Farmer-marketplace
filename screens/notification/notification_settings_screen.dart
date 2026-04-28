import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  
  bool _orderUpdates = true;
  bool _paymentUpdates = true;
  bool _promotionalOffers = true;
  bool _newMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          // Notification Channels
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notification Channels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications on your device'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Receive notifications via text message'),
            value: _smsNotifications,
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          
          const Divider(height: 32),
          
          // Notification Types
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notification Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Order Updates'),
            subtitle: const Text('Order confirmation, shipping, delivery updates'),
            value: _orderUpdates,
            onChanged: (value) {
              setState(() {
                _orderUpdates = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Payment Updates'),
            subtitle: const Text('Payment confirmation and receipts'),
            value: _paymentUpdates,
            onChanged: (value) {
              setState(() {
                _paymentUpdates = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Promotional Offers'),
            subtitle: const Text('Discounts, deals, and special offers'),
            value: _promotionalOffers,
            onChanged: (value) {
              setState(() {
                _promotionalOffers = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('New Messages'),
            subtitle: const Text('Chat messages from farmers and buyers'),
            value: _newMessages,
            onChanged: (value) {
              setState(() {
                _newMessages = value;
              });
            },
            activeThumbColor: AppColors.primary,
          ),
          
          const SizedBox(height: 30),
          
          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings saved successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}