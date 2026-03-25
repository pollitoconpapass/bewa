import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/info_models.dart';
import '../providers/locale_provider.dart';
import '../services/authorizer.dart';
import '../services/db_connector.dart';
import '../themes/palette.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final email = await Authorizer.getUserEmail();
    if (email != null) {
      var db = await DBConnector.connect();
      var user = await DBConnector.getUser(db, email);
      await DBConnector.close(db);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await Authorizer.clearUserEmail();
    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/signin', (route) => false);
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: mainTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryColor,
                    child: Icon(Icons.person, size: 50, color: cardColor),
                  ),
                  const SizedBox(height: 16),
                  if (_user != null) ...[
                    Text(
                      _user!.name,
                      style: TextStyle(
                        color: mainTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _user!.email,
                      style: TextStyle(color: labelsColor, fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: _getLanguageName(
                      localeProvider.locale.languageCode,
                    ),
                    onTap: () => _showLanguageDialog(localeProvider),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    subtitle: 'Sign out of your account',
                    onTap: _logout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColorSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : iconsBlocksColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : mainTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: labelsColor)),
        trailing: Icon(Icons.chevron_right, color: labelsColor),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog(LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Select Language', style: TextStyle(color: mainTextColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'en',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Español'),
              leading: Radio<String>(
                value: 'es',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) {
                  localeProvider.setLocale(const Locale('es'));
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
