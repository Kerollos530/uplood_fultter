# Smart Transit App

A complete Flutter Front-End only mobile application for public transport navigation in Greater Cairo.

## Features
- **Smart Routing**: Dijkstra algorithm finding best path across Metro, Monorail, LRT, and BRT.
- **Mock Authentication**: Login/Signup flows.
- **Tourist Mode**: Navigate to famous landmarks.
- **Digital Ticketing**: QR Code generation.
- **History**: Local storage of trips.
- **Bilingual**: English / Arabic support.

## Project Structure
- `lib/models`: Data models.
- `lib/data/mock_data`: Static graph data for stations and connections.
- `lib/services`: Logical services (Routing, Auth, Payment).
- `lib/state`: Riverpod providers.
- `lib/screens`: UI Screens.
- `lib/theme`: App theming.

## How to Run
1. Ensure Flutter is installed.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to launch the app on your emulator or device.

## Mocks & Assumptions
- **GPS**: Defaults to 'Maadi' as starting point if GPS permission not granted (Mock behavior).
- **Payment**: Simulates a successful transaction after 2 seconds.
- **Auth**: Accepts any email with '@' and password length > 5.

## Assets
Place the following images in `assets/images/` for full experience:
- `pyramids.jpg`
- `cairo_tower.jpg`
- `azhar.jpg`
(The app handles missing images gracefully).
