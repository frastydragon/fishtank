import 'package:flutter/material.dart';

void main() {
  runApp(AquariumApp());
}

class AquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}
class Fish {
  final Color color;
  final double speed;

  Fish({required this.color, required this.speed});
}

class _AquariumScreenState extends State<AquariumScreen> {
  List<Fish> fishList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
      ),
      body: Column(
        children: [
          Container(
            width: 300,
            height: 300,
            color: Colors.blue[100],
            child: Stack(
              children: [
                // Fish animations will go here
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _addFish,
            child: Text('Add Fish'),
          ),
          // Add sliders for speed and color selection here
        ],
      ),
    );
  }
  
  void _addFish() {
    // Add fish logic here
    if (fishList.length < 10) { // Limiting to 10 fish
      setState(() {
      fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
      });
    }
  }
}

