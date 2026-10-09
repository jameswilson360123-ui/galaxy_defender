# Galaxy Defender

A playable 2D arcade space shooter built with Flutter and Flame.

## Features

- Playable main menu and player controls
- Touch drag movement and auto-fire
- Enemy waves with basic boss encounter
- Power-ups, scoring, lives, and shields
- Hangar and upgrade screens with persistent local save
- Settings screen with saved preferences
- No remote services required

## Setup

```bash
flutter pub get
flutter run
```

## Controls

- Drag on the game area to move the ship
- Tap the special action in the overlay or tap the screen to trigger pulse
- Use the pause button in game HUD

## Project structure

- `lib/app` for routed app and app shell
- `lib/game` for the Flame game and gameplay components
- `lib/data` for local persistence models and storage logic
- `lib/screens` for menu, hangar, settings, and upgrades
- `lib/widgets` for reusable UI controls
