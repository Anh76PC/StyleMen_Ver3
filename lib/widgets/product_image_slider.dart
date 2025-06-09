import 'package:flutter/material.dart';

class ProductImageSlider extends StatefulWidget {
  final String productId;
  final List<dynamic> images;
  final ValueNotifier<String?> primaryImageNotifier;

  const ProductImageSlider({
    super.key,
    required this.productId,
    required this.images,
    required this.primaryImageNotifier,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Reset to first page when primary image changes
    widget.primaryImageNotifier.addListener(() {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
        setState(() {
          _currentPage = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: ValueListenableBuilder<String?>(
        valueListenable: widget.primaryImageNotifier,
        builder: (context, primaryImage, child) {
          // Combine primary image (if available) with product images
          final displayImages = [
            if (primaryImage != null) primaryImage,
            ...widget.images,
          ].toSet().toList(); // Remove duplicates

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: displayImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = displayImages[index];
                  // Determine if the image is a variant image (starts with http) or product image
                  final isVariantImage = imageUrl.startsWith('http');
                  final url = isVariantImage
                      ? imageUrl
                      : 'http://pocketbase.anhpc.online:8090/api/files/products/${widget.productId}/$imageUrl';
                  return ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Image.network(
                      url,
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        width: double.infinity,
                        height: 400,
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Text(
                    '${_currentPage + 1} | ${displayImages.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}