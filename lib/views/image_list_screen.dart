import 'package:flutter/material.dart';
import '../models/vehicle_image.dart';
import '../services/image_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageListScreen extends StatefulWidget {
  const ImageListScreen({super.key});

  @override
  State<ImageListScreen> createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Map<int, List<VehicleImage>> _tabImages = {
    0: [], // Unverified
    1: [], // Verified
    2: [], // Rejected
  };
  Map<int, int> _tabCurrentPage = {
    0: 1,
    1: 1,
    2: 1,
  };
  Map<int, bool> _tabHasMore = {
    0: true,
    1: true,
    2: true,
  };
  Map<int, int> _tabLimits = {
    0: 10,
    1: 10,
    2: 10,
  };
  Map<int, int> _tabTotalPages = {
    0: 1,
    1: 1,
    2: 1,
  };
  final List<int> _availableLimits = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadImages();
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final newTab = _tabController.index;
      // Only reload if this tab hasn't been loaded yet
      if (_tabImages[newTab]!.isEmpty) {
        setState(() {
          _tabCurrentPage[newTab] = 1;
        });
        _loadImages();
      }
    }
  }

  String _getCurrentStatus() {
    switch (_tabController.index) {
      case 0:
        return 'Unverified';
      case 1:
        return 'Verified';
      case 2:
        return 'Rejected';
      default:
        return 'Unverified';
    }
  }

  Widget _buildPaginationControls() {
    final currentTab = _tabController.index;
    final currentPage = _tabCurrentPage[currentTab]!;
    final totalPages = _tabTotalPages[currentTab]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Show limit selector
          Row(
            children: [
              const Text('Show: '),
              DropdownButton<int>(
                value: _tabLimits[currentTab],
                items: _availableLimits.map((limit) {
                  return DropdownMenuItem<int>(
                    value: limit,
                    child: Text('$limit Images'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _handleLimitChange(value);
                  }
                },
              ),
            ],
          ),
          // Right side - Pagination controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage <= 1 ? null : () => _handlePageChange(currentPage - 1),
              ),
              Text('Page $currentPage of $totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage >= totalPages ? null : () => _handlePageChange(currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePageChange(int newPage) {
    final currentTab = _tabController.index;
    if (newPage != _tabCurrentPage[currentTab]) {
      setState(() {
        _tabCurrentPage[currentTab] = newPage;
        _tabImages[currentTab]!.clear();
      });
      _loadImages();
    }
  }

  void _handleLimitChange(int value) {
    final currentTab = _tabController.index;
    if (_tabLimits[currentTab] != value) {
      setState(() {
        _tabLimits[currentTab] = value;
        _tabCurrentPage[currentTab] = 1;
        _tabImages[currentTab]!.clear();
      });
      _loadImages();
    }
  }

  Widget _buildImageGrid() {
    final currentTab = _tabController.index;
    final images = _tabImages[currentTab]!;
    final hasMore = _tabHasMore[currentTab]!;

    if (images.isEmpty && !_isLoading) {
      return const Center(child: Text('No images found'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoading && 
            hasMore && 
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadImages();
        }
        return true;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: images.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == images.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final image = images[index];
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          CachedNetworkImage(
                            imageUrl: image.imageURL,
                            fit: BoxFit.contain,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Detection ID: ${image.detectionID}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: image.verificationStatus == 'Unverified'
                      ? Colors.orange
                      : image.verificationStatus == 'Verified'
                          ? Colors.green
                          : Colors.red,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: image.imageURL,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadImages() async {
    final currentTab = _tabController.index;
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ImageService.getImages(
        page: _tabCurrentPage[currentTab]!,
        limit: _tabLimits[currentTab]!
      );
      
      if (result == null || !result.containsKey('images') || !result.containsKey('totalPages') || !result.containsKey('currentPage')) {
        print('Invalid API response structure: $result');
        throw Exception('Invalid API response structure');
      }

      print('API Response - Total Pages: ${result['totalPages']}');
      print('API Response - Current Page: ${result['currentPage']}');
      print('API Response - Total Images: ${(result['images'] as List).length}');
      
      if (!mounted) return;

      final currentStatus = _getCurrentStatus();
      print('Current Tab Status: $currentStatus');
      
      final List<VehicleImage> allImages = result['images'] as List<VehicleImage>;
      print('All Images Count: ${allImages.length}');
      
      // Filter images based on current tab's status
      final filteredImages = allImages.where((image) {
        print('Image ${image.id} Status: ${image.verificationStatus}');
        return image.verificationStatus == currentStatus;
      }).toList();
      
      print('Filtered Images Count: ${filteredImages.length}');

      if (mounted) {
        setState(() {
          // Only take up to the limit of images
          _tabImages[currentTab] = filteredImages.take(_tabLimits[currentTab]!).toList();
          print('Total Images in Tab ${currentTab}: ${_tabImages[currentTab]!.length}');
          
          // Update total pages based on API response
          _tabTotalPages[currentTab] = result['totalPages'] as int;
          
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading images: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load images. Please try again later.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image List'),
        backgroundColor: const Color(0xFF008DB9),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Unverified'),
            Tab(text: 'Verified'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPaginationControls(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildImageGrid(),
                _buildImageGrid(),
                _buildImageGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}