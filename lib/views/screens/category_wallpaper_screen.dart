import 'package:flutter/material.dart';
import 'package:task_2/api/api_service.dart';
import 'package:task_2/models/wallpaper_model.dart';
import 'package:task_2/views/screens/detail_screen.dart';
import 'package:task_2/widgets/wallpaper_tile.dart';

class CategoryWallpaperScreen extends StatefulWidget {
  final String category;
  final String bannerImageUrl;

  const CategoryWallpaperScreen({
    super.key,
    required this.category,
    required this.bannerImageUrl,
  });

  @override
  State<CategoryWallpaperScreen> createState() => _CategoryWallpaperScreenState();
}

class _CategoryWallpaperScreenState extends State<CategoryWallpaperScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<Wallpaper> _wallpapers = [];
  //int _currentPage = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchWallpapers() async {
    setState(() => _isLoading = true);
    try {
      final wallpapers = await _apiService.fetchWallpapersByCategory(widget.category);
      setState(() {
        _wallpapers = wallpapers;
        _isLoading = false;
        _hasMore = wallpapers.length == 20;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    //_currentPage++;

    try {
      final moreWallpapers = await _apiService.fetchWallpapersByCategory(widget.category, );
      setState(() {
        _wallpapers.addAll(moreWallpapers);
        _isLoadingMore = false;
        if (moreWallpapers.length < 20) _hasMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.black,
                  pinned: true,
                  expandedHeight: 250,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text(
                      '${widget.category} wallpaper',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                      ),
                    ),
                    background: Image.network(
                      widget.bannerImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final wallpaper = _wallpapers[index];
                        return WallpaperTile(
                          wallpaper: wallpaper,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(wallpaper: wallpaper),
                              ),
                            );
                          },
                        );
                      },
                      childCount: _wallpapers.length,
                    ),
                  ),
                ),
                if (_isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                  ),
              ],
            ),
    );
  }
}
