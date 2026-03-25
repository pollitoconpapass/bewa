import 'package:flutter/material.dart';

import '../models/info_models.dart';
import '../services/authorizer.dart';
import '../services/db_connector.dart';
import '../screens/profile_screen.dart';
import '../themes/palette.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _recentlyPlayed = [];
  final List<Map<String, dynamic>> _forYou = [];
  final List<Map<String, dynamic>> _topHits = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Hello, ${_user?.name ?? 'User'}',
          style: TextStyle(
            color: mainTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: iconsBlocksColor, size: 30.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSection(
                    'Recently Played',
                    _recentlyPlayed,
                    emptyMessage: 'No recently played songs',
                    emptyImage: 'assets/imgs/man-achordeon.png',
                    isCircular: true,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Your Playlists',
                    _forYou,
                    emptyMessage: 'No playlists yet',
                    emptyImage: 'assets/imgs/woman-dj.png',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Top Hits',
                    _topHits,
                    emptyMessage: 'No top hits available',
                    emptyImage: 'assets/imgs/woman-singing.png',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(
    String title,
    List<Map<String, dynamic>> items, {
    required String emptyMessage,
    required String emptyImage,
    bool isCircular = false,
  }) {
    final bool isEmpty = items.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'See more',
                style: TextStyle(color: labelsColor, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: isCircular ? 130 : 160,
          child: isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        emptyImage,
                        width: isCircular ? 100 : 120,
                        height: isCircular ? 100 : 120,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emptyMessage,
                        style: TextStyle(color: labelsColor, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: isCircular ? 80 : 120,
                            height: isCircular ? 80 : 120,
                            decoration: BoxDecoration(
                              borderRadius: isCircular
                                  ? BorderRadius.circular(40)
                                  : BorderRadius.circular(12),
                              color: cardColorSoft,
                              image: DecorationImage(
                                image: AssetImage(items[index]['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: isCircular ? 80 : 120,
                            child: Text(
                              items[index]['title'],
                              style: TextStyle(
                                color: mainTextColor,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
