import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(AquariumApp());
}

class AquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen>
    with SingleTickerProviderStateMixin {
  List<Fish> fishList = [];
  Color selectedColor = Colors.red;
  double selectedSpeed = 1.0;
  late AnimationController _controller;
  late Database database;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    initDatabase();
  }

  Future<void> initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'aquarium.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE settings(id INTEGER PRIMARY KEY, fishCount INTEGER, speed REAL, color TEXT)",
        );
      },
      version: 1,
    );
    loadSettings();
  }

  Future<void> saveSettings() async {
    await database.insert(
      'settings',
      {
        'id': 1,
        'fishCount': fishList.length,
        'speed': selectedSpeed,
        'color': selectedColor.value.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> loadSettings() async {
    final List<Map<String, dynamic>> settings = await database.query('settings');
    if (settings.isNotEmpty) {
      final setting = settings.first;
      setState(() {
        int fishCount = setting['fishCount'];
        selectedSpeed = setting['speed'];
        selectedColor = Color(int.parse(setting['color']));
        for (int i = 0; i < fishCount; i++) {
          fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    database.close();
    super.dispose();
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('My Virtual Aquarium'),
          centerTitle: true, // This centers the title
        ),
      body: Column(
        children: [
          Container(
            width: 600,
            height: 400,
            color: Colors.blue[100],
            child: Stack(
              children: fishList.map((fish) => FishWidget(fish: fish, controller: _controller)).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _addFish, child: Text('Add Fish')),
              ElevatedButton(onPressed: saveSettings, child: Text('Save Settings')),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Adjust Speed', style: TextStyle(fontSize: 16)),
            SizedBox(
              width: 400, // Set a smaller width for the slider
              child: Slider(
                value: selectedSpeed,
                min: 0.5,
                max: 5.0,
                divisions: 10,
                label: 'Speed: ${selectedSpeed.toStringAsFixed(1)}',
                onChanged: (value) {
                  setState(() {
                  selectedSpeed = value;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Fish Color: ', style: TextStyle(fontSize: 16)),
            DropdownButton<Color>(
            value: selectedColor,
            items: <Color>[Colors.red, Colors.green, Colors.blue, Colors.yellow]
                .map((color) => DropdownMenuItem(
                      value: color,
                      child: Container(
                        width: 24,
                        height: 24,
                        color: color,
                      ),
                    ))
                .toList(),
            onChanged: (color) {
              setState(() {
                selectedColor = color!;
              });
            },
          ),
          ],
        ),
        ],
      ),
    );
  }
}

class Fish {
  final Color color;
  final double speed;

  Fish({required this.color, required this.speed});
}

class FishWidget extends StatefulWidget {
  final Fish fish;
  final AnimationController controller;

  FishWidget({required this.fish, required this.controller});

  @override
  _FishWidgetState createState() => _FishWidgetState();
}

class _FishWidgetState extends State<FishWidget> {
  late double dx;
  late double dy;
  late double directionX;
  late double directionY;

  @override
  void initState() {
    super.initState();
    final random = Random();
    dx = random.nextDouble() * 250;
    dy = random.nextDouble() * 250;
    directionX = (random.nextBool() ? 1 : -1).toDouble();
    directionY = (random.nextBool() ? 1 : -1).toDouble();
    widget.controller.addListener(_updatePosition);
  }

  void _updatePosition() {
    setState(() {
      dx += directionX * widget.fish.speed;
      dy += directionY * widget.fish.speed;

      if (dx <= 0 || dx >= 570) directionX *= -1;
      if (dy <= 0 || dy >= 370) directionY *= -1;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePosition);
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    return Positioned(
      left: dx,
      top: dy,
      child: CustomPaint(
        painter: FishPainter(widget.fish.color),
        size: Size(40, 20), // Size of the fish shape
      ),
    );
  }
}

class FishPainter extends CustomPainter {
  final Color color;

  FishPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    //Body of the fish (ellipse shape)
    final bodyPath = Path()
      ..moveTo(size.width * 0.2, size.height / 2)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.8, size.width * 0.8, size.height / 2)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.2, size.width * 0.2, size.height / 2)
      ..close();

    //Tail of the fish (triangle shape)
    final tailPath = Path()
      ..moveTo(size.width * 0.8, size.height / 2)
      ..lineTo(size.width, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.7)
      ..close();

    //Draw the fish body
    canvas.drawPath(bodyPath, paint);
    //Draw the fish tail
    canvas.drawPath(tailPath, paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}