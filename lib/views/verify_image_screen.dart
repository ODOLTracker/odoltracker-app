import 'package:flutter/material.dart';
import '../models/vehicle_image.dart';
import '../services/image_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'image_list_screen.dart';

class VerifyImageScreen extends StatefulWidget {
  const VerifyImageScreen({super.key});

  @override
  State<VerifyImageScreen> createState() => _VerifyImageScreenState();
}

class _VerifyImageScreenState extends State<VerifyImageScreen> {
  List<VehicleImage> _images = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isVerifying = false;
  int _currentImageIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadImages();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _initPageController() {
    if (_pageController == null || !_pageController!.hasClients) {
      _pageController?.dispose();
      _pageController = PageController(initialPage: _currentImageIndex);
    }
  }

  Future<void> _loadImages() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get all images without filtering at API level
      final result = await ImageService.getImages(
        page: _currentPage,
        limit: 100, // Increased limit to get more images at once
      );
      
      if (mounted) {
        // Filter unverified images after getting all images
        final allImages = result['images'] as List<VehicleImage>;
        final filteredImages = allImages.where(
          (image) => image.verificationStatus == 'Unverified'
        ).toList();

        setState(() {
          _images = filteredImages;
          // Update pagination based on filtered results
          _totalPages = (filteredImages.length / 100).ceil();
          
          // Reset current image index when loading new images
          if (_currentImageIndex >= _images.length) {
            _currentImageIndex = 0;
          }
        });

        // Handle page controller after state is updated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _images.isNotEmpty) {
            _initPageController();
            if (_pageController?.hasClients ?? false) {
              _pageController?.jumpToPage(_currentImageIndex);
            }
          }
        });

        // If no unverified images found in current page, try next page
        if (filteredImages.isEmpty && _currentPage < result['totalPages']) {
          _currentPage++;
          _loadImages();
        }
      }
    } catch (e) {
      print('Error loading images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading images: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyImage(bool isVerified) async {
    if (_images.isEmpty || _isVerifying) return;

    final currentImage = _images[_currentImageIndex];
    
    setState(() {
      _isVerifying = true;
    });

    try {
      final success = await ImageService.verifyImage(
        currentImage.id,
        isVerified ? 'Verified' : 'Rejected',
      );
      
      if (success && mounted) {
        // Remove the verified image from the list
        setState(() {
          _images.removeAt(_currentImageIndex);
          
          // If no more images in current page, load next page
          if (_images.isEmpty && _currentPage < _totalPages) {
            _currentPage++;
            _loadImages();
          } else if (_currentImageIndex >= _images.length) {
            // Adjust current index if needed
            _currentImageIndex = _images.isEmpty ? 0 : _images.length - 1;
            _pageController?.jumpToPage(_currentImageIndex);
          }
        });

        // Show snackbar with action to view all images
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isVerified ? 'Image verified' : 'Image rejected'),
              action: SnackBarAction(
                label: 'View All',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImageListScreen(),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error verifying image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying image: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Violation'),
        backgroundColor: const Color(0xFF008DB9),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImageListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? const Center(child: Text('No images to verify'))
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            itemCount: _images.length,
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final image = _images[index];
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: CachedNetworkImage(
                                        imageUrl: image.imageURL,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) =>
                                            const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Detection ID: ${image.detectionID}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Status: ${image.verificationStatus}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: image.verificationStatus == 'Unverified'
                                            ? Colors.orange
                                            : image.verificationStatus == 'Verified'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FloatingActionButton(
                                heroTag: 'reject_button',
                                onPressed: _isVerifying ? null : () => _verifyImage(false),
                                backgroundColor: _isVerifying ? Colors.grey : Colors.red,
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                              FloatingActionButton(
                                heroTag: 'verify_button',
                                onPressed: _isVerifying ? null : () => _verifyImage(true),
                                backgroundColor: _isVerifying ? Colors.grey : Colors.green,
                                child: const Icon(Icons.check, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isVerifying)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
    );
  }
} 