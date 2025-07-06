import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:task_2/api/api_service.dart';
import 'package:task_2/models/wallpaper_model.dart';
import 'package:task_2/views/screens/category_tile.dart';
import 'package:task_2/views/screens/category_wallpaper_screen.dart';
import 'package:task_2/views/screens/search_screen.dart';
//import 'package:task_2/widgets/wallpaper_tile.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final List<Wallpaper> _wallpapers = [];
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  late PageController _pageController;
  int _currentIndex = 0;
  final List<String> _categories = [
    'pattern', 'car', 'nature', 'city', 'black', 'flowers', 'abstract'
  ];

  @override
  void initState() {
    super.initState();

    super.initState();
  _pageController = PageController(viewportFraction: 0.87);
  _pageController.addListener(() {
    if (_pageController.page != null &&
        _pageController.page! >= _wallpapers.length - 1 &&
        _hasMore &&
        !_isLoading) {
      _loadMore();
    }
  });
    _loadWallpapers();
     _loadCategories(); 
  }

  Future<void> _loadWallpapers() async {
    setState(() => _isLoading = true);
    final newWallpapers = await _apiService.fetchWallpapers(page: _page);

    setState(() {
      _wallpapers.addAll(newWallpapers);
      _isLoading = false;
      if (newWallpapers.isEmpty) {
        _hasMore = false;
      }
    });
  }
  List<Map<String, String>> _categoryData = [];

Future<void> _loadCategories() async {
  for (final category in _categories) {
    final imageUrl = await _apiService.fetchCategoryImage(category);
    if (imageUrl != null) {
      _categoryData.add({
        'category': category,
        'imageUrl': imageUrl,
      });
    }
  }
  setState(() {});
}
  void _loadMore() {
    if (_hasMore && !_isLoading) {
      _page++;
      _loadWallpapers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
         backgroundColor: const Color.fromARGB(255, 28, 28, 30),
        centerTitle: true,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                 cursorColor: Colors.purpleAccent,
                decoration: const InputDecoration(
                  hintText: 'Search wallpapers...',
                  hintStyle: TextStyle(color: Colors.white),
                
                   enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent),
            ),
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
          Padding(
             padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: SizedBox(
              height: 70,
             
              child: Center(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categoryData.length,
                  itemBuilder: (context, index) {
                    final item = _categoryData[index];
                    return GestureDetector(
                       onTap: () async {
        
          //final String category = item['category']!;
          //final List<Wallpaper> wallpapers = await _apiService.fetchWallpapersByCategory(category);

          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryWallpaperScreen(
                category: item['category']!,
                bannerImageUrl: item['imageUrl']!,
                // wallpapers: wallpapers,
              ),
            ),
          );
        },
                 
                    child: CategoryTile(
                      category: item['category']!,
                      imageUrl: item['imageUrl']!,
                    )
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
     Expanded(
  child: CarouselSlider.builder(
    itemCount: _wallpapers.length + ((_wallpapers.length % 20 == 0 && _hasMore) ? 1 : 0),
    options: CarouselOptions(
      height: MediaQuery.of(context).size.height * 0.67,
      enlargeCenterPage: true,
      viewportFraction: 0.75,
      onPageChanged: (index, reason) {
        setState(() {
          _currentIndex = index;
        });
      },
    ),
    itemBuilder: (context, index, realIdx) {
      
      if (index == _wallpapers.length) {
        return Center(
          child: GestureDetector(
            onTap: _loadMore,
            child: Container(
              width: 160,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "Load More",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final wallpaper = _wallpapers[index];
      final bool isCenter = index == _currentIndex;

      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(wallpaper: wallpaper),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: isCenter
                ? [
                    const BoxShadow(
                      color: Colors.black54,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    )
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
            image: DecorationImage(
              image: NetworkImage(wallpaper.imageUrl),
              fit: BoxFit.cover,
              colorFilter: isCenter
                  ? null
                  : ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
            ),
          ),
        ),
      );
    },
  ),
),


          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
