import 'package:flutter/material.dart';
import 'package:task_2/api/api_service.dart';
import 'package:task_2/models/wallpaper_model.dart';
import 'package:task_2/widgets/loading_spinner.dart';
import 'package:task_2/widgets/wallpaper_tile.dart';

import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;

  const SearchScreen({super.key, required this.searchQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //late TextEditingController _controller;
  final ApiService _apiService = ApiService();
  List<Wallpaper> _results = [];
  bool _loading = false;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
   //bool _loading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
   final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
   // _controller = TextEditingController(text: widget.searchQuery);
    _searchInitial(widget.searchQuery);
       _scrollController.addListener(_onScroll); // search on load
  }

  void _searchInitial(String keyword) async {
    if (keyword.isEmpty) return;
    setState(() => _loading = true);
    final wallpapers = await _apiService.searchWallpapers(keyword);
    setState(() {
      _results = wallpapers;
      _loading = false;
    });
  }
  void _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final newWallpapers = await _apiService.searchWallpapers(widget.searchQuery, page: _currentPage);
      setState(() {
        _results.addAll(newWallpapers);
        _isLoadingMore = false;
        if (newWallpapers.length < 20) _hasMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !_isLoadingMore) {
      _loadMore();
    }
  }
  // void _search() async {
  //   if (_controller.text.isEmpty) return;
  //   FocusScope.of(context).unfocus();
  //   setState(() => _loading = true);
  //   final wallpapers = await _apiService.searchWallpapers(_controller.text.trim());
  //   setState(() {
  //     _results = wallpapers;
  //     _loading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar( backgroundColor: const Color.fromARGB(115, 121, 115, 115),
        centerTitle: true,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search wallpapers...',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SearchScreen(searchQuery: value.trim()),
                      ),
                    );
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                    });
                  }
                },
              )
            : const Text(
                'FLUX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 22,
                ),
              ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: TextField(
          //     controller: _controller,
          //     decoration: InputDecoration(
          //       hintText: "Search...",
          //       suffixIcon: IconButton(
          //         icon: const Icon(Icons.search),
          //         onPressed: _search,
          //       ),
          //     ),
          //     onSubmitted: (_) => _search(),
          //   ),
          // ),
          Expanded(
            child: _loading
                ? const LoadingSpinner()
                : _results.isEmpty
                    ? const Center(child: Text("No results found"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final wallpaper = _results[index];
                          return WallpaperTile(
                            wallpaper: wallpaper,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(wallpaper: wallpaper),
                              ),
                            ),
                          );
                        },
                      ),
          ),
           if (_isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
        ],
      ),
      
    );
  }
}
