import 'package:flutter/material.dart';

import '../models/info_models.dart';
import '../services/song_service.dart';
import '../themes/palette.dart';

class SearchBar extends StatefulWidget {
  final bool isExploring;
  final Function(String)? onChanged;
  final Function(List<Song>)? onSongsFound;

  const SearchBar({
    super.key,
    required this.isExploring,
    this.onChanged,
    this.onSongsFound,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final SongService _songService = SongService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _songService.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) return;

    if (widget.isExploring) {
      setState(() => _isLoading = true);
      try {
        final songs = await searchSongs(query);
        if (widget.onSongsFound != null) {
          widget.onSongsFound!(songs);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching songs: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      // For local search, we might just trigger the onChanged if needed
      if (widget.onChanged != null) {
        widget.onChanged!(query);
      }
    }
  }

  Future<List<Song>> searchSongs(String query) async {
    List<SongResult> songResults = await _songService.searchSong(query);

    return songResults.map((songResult) {
      return Song(
        id: '', // Local database ID, remains empty for search results
        externalId: songResult.id,
        title: songResult.title,
        artist: songResult.artist,
        artistId: songResult.artistId,
        image: songResult.thumbnail,
        duration: songResult.duration ?? 0.0,
        url: songResult.url,
        savedAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
          setState(() {});
        },
        onSubmitted: _handleSearch,
        style: const TextStyle(color: mainTextColor),
        decoration: InputDecoration(
          hintText: widget.isExploring ? 'Search for songs...' : 'Search in library...',
          hintStyle: const TextStyle(color: labelsColor),
          prefixIcon: const Icon(Icons.search, color: iconsBlocksColor),
          suffixIcon: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                )
              : _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: iconsBlocksColor),
                      onPressed: () {
                        _controller.clear();
                        if (widget.onChanged != null) {
                          widget.onChanged!('');
                        }
                        setState(() {});
                      },
                    )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
