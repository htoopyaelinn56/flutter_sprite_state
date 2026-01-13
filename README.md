# Flame Sprite State Demo

This is a Flutter project demonstrating sprite animation state management using the Flame engine.

## Description

This project showcases a simple game character (a cat) with multiple states:
- Idle
- Walking
- Attacking
- Taking a hit
- Dying

The character's state can be changed by interacting with it. When the character's state is "dead", a "Restart" button appears, which allows resetting the character's state.

This project is a good example for learning how to handle sprite animations and state transitions in a Flame game.

## Features

- Sprite animation for different character states.
- State management for a game character.
- Interaction with the game character to change its state.
- Overlaying Flutter widgets (like a restart button) on top of the game canvas.
- Communication between the Flame game and the Flutter widget tree.

## How to Run

1.  Make sure you have Flutter installed.
2.  Clone this repository.
3.  Navigate to the project directory: `cd flame_sprite_state`
4.  Install dependencies: `flutter pub get`
5.  Run the app: `flutter run`
