# Women Safety App

A comprehensive Flutter application focused on women's safety, featuring location-based reviews, emergency contacts, and real-time safety information.

## Features

### 1. Safety Map
- Interactive map showing current location and nearby safety information
- View safety reviews within 5KM radius of your route
- Search for destinations and view safety ratings
- Add safety reviews for locations
- Real-time location tracking
- Route visualization with safety zones

### 2. Location Reviews
- Rate locations based on safety (1-5 stars)
- Add detailed safety reviews
- View reviews from other users
- Filter reviews by:
  - Rating
  - Distance
  - Date
- Reviews are displayed on the map with star markers
- Each review shows:
  - Safety rating
  - Review text
  - Posted time
  - User information

### 3. Emergency Contacts
- Add and manage emergency contacts
- Quick access to emergency numbers
- Direct call functionality
- Contact categorization

### 4. Safety Tips
- Access safety guidelines
- View emergency procedures
- Learn self-defense tips
- Get location-specific safety advice

### 5. User Interface
- Dark/Light mode support
- Multi-language support (English, Hindi, Tamil)
- Intuitive navigation
- Responsive design

## Technical Features

- Real-time location tracking using Geolocator
- Interactive maps with FlutterMap
- Firebase integration for:
  - User authentication
  - Review storage
  - Real-time updates
- Offline support for basic features
- Location-based services
- Route optimization

## Getting Started

1. Clone the repository
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add your Firebase configuration files
   - Enable required Firebase services
4. Run the app:
   ```bash
   flutter run
   ```

## Requirements

- Flutter SDK
- Android Studio / VS Code
- Firebase account
- Google Maps API key (for map features)
- Location permissions enabled on device

## Permissions Required

- Location access (for map and safety features)
- Internet access
- Camera (for photo uploads)
- Storage (for saving data)
- Phone (for emergency calls)
- Contacts (for emergency contacts)

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- OpenStreetMap for map data
- All contributors and users of the app
