import 'dart:async';
import 'package:flutter/material.dart';

import '../themes/palette.dart';

class Artists3DBlock extends StatefulWidget {
  final Function(int)? onPageChanged;

  const Artists3DBlock({super.key, this.onPageChanged});

  @override
  State<Artists3DBlock> createState() => _Artists3DBlockState();
}

class _Artists3DBlockState extends State<Artists3DBlock> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _artistImages = [
    'assets/imgs/3D/Adele.png',
    'assets/imgs/3D/Ariana-Grande.png',
    'assets/imgs/3D/Beyonce.png',
    'assets/imgs/3D/Billie-Eilish.png',
    'assets/imgs/3D/Bruno-Mars.png',
    'assets/imgs/3D/Doja-Cat.png',
    'assets/imgs/3D/Drake.png',
    'assets/imgs/3D/Dua-lipa.png',
    'assets/imgs/3D/Ed-Sheeran.png',
    'assets/imgs/3D/Elvis-Presley.png',
    'assets/imgs/3D/Freddie-Mercury.png',
    'assets/imgs/3D/Justin-Bieber.png',
    'assets/imgs/3D/Katy-Perry.png',
    'assets/imgs/3D/Lady-Gaga.png',
    'assets/imgs/3D/Lil-Wayne.png',
    'assets/imgs/3D/Michael-Jackson.png',
    'assets/imgs/3D/Miley-Cyrus.png',
    'assets/imgs/3D/Post-Malone.png',
    'assets/imgs/3D/Taylor-Swift.png',
    'assets/imgs/3D/The-Weeknd.png',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _artistImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          widget.onPageChanged?.call(index);
        },
        itemCount: _artistImages.length,
        itemBuilder: (context, index) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: backgroundColor,
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                _artistImages[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: labelsColor,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
