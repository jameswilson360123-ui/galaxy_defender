import 'package:flutter/material.dart';
import 'package:galaxy_defender/data/game_save.dart';
import 'package:galaxy_defender/widgets/game_button.dart';

class HangarScreen extends StatefulWidget {
  const HangarScreen({super.key});

  @override
  State<HangarScreen> createState() => _HangarScreenState();
}

class _HangarScreenState extends State<HangarScreen> {
  final ships = const [
    {'name': 'Astra-X', 'summary': 'Balanced starter fighter', 'speed': 1.0, 'damage': 1.0, 'hp': 1.0},
    {'name': 'Phantom', 'summary': 'Fast maneuver fighter', 'speed': 1.4, 'damage': 1.0, 'hp': 0.9},
    {'name': 'Titan', 'summary': 'Heavy durable fighter', 'speed': 0.8, 'damage': 1.2, 'hp': 1.6},
    {'name': 'Nova', 'summary': 'Energy weapon specialist', 'speed': 1.1, 'damage': 1.5, 'hp': 1.1},
  ];

  GameSave save = GameSave.initial();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hangar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Credits: ${save.credits}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...ships.asMap().entries.map((entry) {
              final index = entry.key;
              final ship = entry.value;
              final selected = save.selectedShip == index;
              return Card(
                color: selected ? const Color(0xFF191E3A) : null,
                child: ListTile(
                  title: Text(ship['name'] as String),
                  subtitle: Text(ship['summary'] as String),
                  trailing: ElevatedButton(
                    onPressed: selected ? null : () {
                      setState(() {
                        save = save.copyWith(selectedShip: index);
                      });
                    },
                    child: Text(selected ? 'Selected' : 'Select'),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
