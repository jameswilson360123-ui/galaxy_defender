class GameSave {
  final int bestScore;
  final int credits;
  final int selectedShip;
  final List<bool> unlockedShips;
  final Map<String, int> upgrades;
  final bool musicEnabled;
  final bool sfxEnabled;
  final bool vibrationEnabled;
  final double musicVolume;
  final double sfxVolume;
  final double controlsSensitivity;

  const GameSave({
    this.bestScore = 0,
    this.credits = 0,
    this.selectedShip = 0,
    this.unlockedShips = const [true, false, false, false],
    this.upgrades = const {
      'hull': 0,
      'shield': 0,
      'damage': 0,
      'fireRate': 0,
      'speed': 0,
      'special': 0,
    },
    this.musicEnabled = true,
    this.sfxEnabled = true,
    this.vibrationEnabled = true,
    this.musicVolume = 0.8,
    this.sfxVolume = 0.8,
    this.controlsSensitivity = 1.0,
  });

  factory GameSave.initial() => const GameSave();

  GameSave copyWith({
    int? bestScore,
    int? credits,
    int? selectedShip,
    List<bool>? unlockedShips,
    Map<String, int>? upgrades,
    bool? musicEnabled,
    bool? sfxEnabled,
    bool? vibrationEnabled,
    double? musicVolume,
    double? sfxVolume,
    double? controlsSensitivity,
  }) {
    return GameSave(
      bestScore: bestScore ?? this.bestScore,
      credits: credits ?? this.credits,
      selectedShip: selectedShip ?? this.selectedShip,
      unlockedShips: unlockedShips ?? this.unlockedShips,
      upgrades: upgrades ?? this.upgrades,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      controlsSensitivity: controlsSensitivity ?? this.controlsSensitivity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bestScore': bestScore,
      'credits': credits,
      'selectedShip': selectedShip,
      'unlockedShips': unlockedShips,
      'upgrades': upgrades,
      'musicEnabled': musicEnabled,
      'sfxEnabled': sfxEnabled,
      'vibrationEnabled': vibrationEnabled,
      'musicVolume': musicVolume,
      'sfxVolume': sfxVolume,
      'controlsSensitivity': controlsSensitivity,
    };
  }

  factory GameSave.fromJson(Map<String, dynamic> map) {
    final unlockedShips = (map['unlockedShips'] as List<dynamic>? ?? [true, false, false, false])
        .map((value) => value == true)
        .toList();
    final upgrades = <String, int>{} ;
    final rawUpgrades = map['upgrades'] as Map<String, dynamic>? ?? const {};
    for (final entry in rawUpgrades.entries) {
      upgrades[entry.key] = (entry.value as num?)?.toInt() ?? 0;
    }
    final defaultUpgrades = const {
      'hull': 0,
      'shield': 0,
      'damage': 0,
      'fireRate': 0,
      'speed': 0,
      'special': 0,
    };
    for (final entry in defaultUpgrades.entries) {
      upgrades.putIfAbsent(entry.key, () => entry.value);
    }

    return GameSave(
      bestScore: (map['bestScore'] as num?)?.toInt() ?? 0,
      credits: (map['credits'] as num?)?.toInt() ?? 0,
      selectedShip: (map['selectedShip'] as num?)?.toInt() ?? 0,
      unlockedShips: unlockedShips.length >= 4 ? unlockedShips : [true, false, false, false],
      upgrades: upgrades,
      musicEnabled: map['musicEnabled'] as bool? ?? true,
      sfxEnabled: map['sfxEnabled'] as bool? ?? true,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
      musicVolume: (map['musicVolume'] as num?)?.toDouble() ?? 0.8,
      sfxVolume: (map['sfxVolume'] as num?)?.toDouble() ?? 0.8,
      controlsSensitivity: (map['controlsSensitivity'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
