import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _routeData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    try {
      final dio = Dio();
      // Mocking the request payload
      final payload = {
        "customer_location": "Entrance",
        "products": [
          {"id": "p1", "name": "Milk", "location": "Aisle_2"},
          {"id": "p2", "name": "Bread", "location": "Aisle_1"},
          {"id": "p3", "name": "Apples", "location": "Aisle_5"}
        ]
      };
      
      final response = await dio.post('http://127.0.0.1:8000/route', data: payload);
      
      setState(() {
        _routeData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load route. Is backend running?";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Navigation')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null 
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildRouteMap(),
    );
  }

  Widget _buildRouteMap() {
    if (_routeData == null) return const SizedBox.shrink();
    
    final distance = _routeData!['total_distance'];
    final time = _routeData!['estimated_walking_time_minutes'];
    final aisles = List<String>.from(_routeData!['aisles']);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Distance', '${distance}m', Icons.straighten),
              _buildStat('Est. Time', '${time} min', Icons.timer),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Optimal Route", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: aisles.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(aisles[index].replaceAll('_', ' ')),
                trailing: index < aisles.length - 1 ? const Icon(Icons.arrow_downward) : const Icon(Icons.flag, color: Colors.green),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
