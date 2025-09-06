import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class DestinationGallery extends StatefulWidget {
  final List<String> imageUrls;

  const DestinationGallery({super.key, required this.imageUrls});

  @override
  State<DestinationGallery> createState() => _DestinationGalleryState();
}

class _DestinationGalleryState extends State<DestinationGallery> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: const Icon(Icons.image, size: 50, color: Colors.grey),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 250,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            viewportFraction: 0.9,
            aspectRatio: 16 / 9,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
        const SizedBox(height: 10),
        // 🔘 Tappable indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
            final isActive = _currentIndex == entry.key;
            return GestureDetector(
              onTap: () => _carouselController.jumpToPage(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 12 : 8,
                height: isActive ? 12 : 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.deepPurple : Colors.grey.shade400,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
