import 'package:flutter/material.dart';
import 'package:position/model/city.dart';
import 'package:position/maps/map_screen.dart';             

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Position Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SearchCityPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/*────────────────────────── SearchCityPage ──────────────────────────*/
class SearchCityPage extends StatefulWidget {
  const SearchCityPage({super.key});

  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  final TextEditingController _controller = TextEditingController();

 
  final List<City> _allCities = const [
    City(name: 'Casablanca',  lat: 33.5731, lng: -7.5898),
    City(name: 'Rabat',       lat: 34.0209, lng: -6.8416),
    City(name: 'Fès',         lat: 34.0331, lng: -5.0000),
    City(name: 'Essaouira',   lat: 31.5085, lng: -9.7680)
  ];

  late List<City> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = _allCities;                 
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase();
    setState(() {
      _filtered = _allCities
          .where((c) => c.name.toLowerCase().contains(query))
          .toList(growable: false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

/*────────────────────────── واجهة البحث ───────────────────────────*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF005AA7), Color(0xFF00C6FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
            
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Rechercher une ville…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text('Aucune ville trouvée',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final city = _filtered[i];
                          return _CityCard(city: city);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*────────────── بطاقة مدينة ──────────────*/
class _CityCard extends StatelessWidget {
  const _CityCard({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: const Icon(Icons.location_city_rounded,
            size: 32, color: Colors.blueAccent),
        title: Text(city.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MapScreen(city: city),
            ),
          );
        },
      ),
    );
  }
}
