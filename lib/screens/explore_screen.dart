import 'package:flutter/material.dart';
import '../themes/palette.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/song_row.dart';
import '../models/info_models.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Song> _searchResults = [];

  void _onSongsFound(List<Song> songs) {
    setState(() {
      _searchResults = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Explore',
          style: TextStyle(
            color: mainTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: custom.SearchBar(
              isExploring: true,
              onSongsFound: _onSongsFound,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'Search for your favorite songs',
                      style: TextStyle(color: labelsColor, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return SongRow(song: _searchResults[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
