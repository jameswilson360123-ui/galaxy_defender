import 'package:flutter/material.dart';
import 'package:galaxy_defender/data/game_save.dart';
import 'package:galaxy_defender/widgets/game_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  GameSave save = GameSave.initial();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Music'),
            value: save.musicEnabled,
            onChanged: (value) => setState(() => save = save.copyWith(musicEnabled: value)),
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: save.sfxEnabled,
            onChanged: (value) => setState(() => save = save.copyWith(sfxEnabled: value)),
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            value: save.vibrationEnabled,
            onChanged: (value) => setState(() => save = save.copyWith(vibrationEnabled: value)),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Control sensitivity'),
            trailing: Text('${save.controlsSensitivity.toStringAsFixed(1)}x'),
          ),
          Slider(
            value: save.controlsSensitivity,
            min: 0.7,
            max: 1.6,
            divisions: 18,
            onChanged: (value) => setState(() => save = save.copyWith(controlsSensitivity: value)),
          ),
          const SizedBox(height: 12),
          GameButton(
            label: 'Reset Progress',
            onPressed: () {
              setState(() => save = GameSave.initial());
            },
          ),
        ],
      ),
    );
  }
}
