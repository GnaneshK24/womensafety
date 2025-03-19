import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reviews_page.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' show Point, sqrt, sin, cos, atan2, pi;
import 'package:cached_network_image/cached_network_image.dart';
import 'location_review_page.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'services/auth_service.dart';
import 'all_reviews_page.dart';
import 'services/location_service.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  late final LocationService _locationService;
  LatLng? currentLocation;
  bool _isLoading = false;
  List<DocumentSnapshot> _reviews = [];
  bool _isLoadingReviews = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _sortBy = 'timestamp';
  double _minRating = 0.0;
  double _maxDistance = 50.0; // in kilometers
  List<LatLng> routePoints = [];
  bool _showRoute = false;
  LatLng? selectedLocation;
  LatLng? destinationLocation;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  List<LatLng> _routeCoordinates = [];
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _locationService = LocationService();
    _initializeLocation();
    _loadReviews();
  }

  Future<void> _initializeLocation() async {
    await _locationService.initialize();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = _locationService
        .getPositionStream(
          desiredAccuracy: LocationAccuracy.high,
          intervalInSeconds: 10,
        )
        .listen(
          (position) {
            setState(() {
              currentLocation = LatLng(position.latitude, position.longitude);
            });
          },
          onError: (e) {
            print('Error in location stream: $e');
          },
        );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final position = await _locationService.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeout: Duration(seconds: 5),
        useLastKnownLocation: true,
      );

      if (position != null) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          if (_mapController.camera.zoom < 15.0) {
            _mapController.move(currentLocation!, 15.0);
          } else {
            _mapController.move(currentLocation!, _mapController.camera.zoom);
          }
        });
      } else {
        // Try to get last known position as fallback
        final lastPosition = await _locationService.getLastKnownPosition();
        if (lastPosition != null) {
          setState(() {
            currentLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
            _mapController.move(currentLocation!, 15.0);
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not get your location. Please check your settings.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location. Using last known location if available.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Add this method to calculate distance from a point to a line segment
  double _distanceFromPointToLineSegment(LatLng point, LatLng lineStart, LatLng lineEnd) {
    final double A = point.latitude - lineStart.latitude;
    final double B = point.longitude - lineStart.longitude;
    final double C = lineEnd.latitude - lineStart.latitude;
    final double D = lineEnd.longitude - lineStart.longitude;

    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;
    double param = -1;

    if (lenSq != 0) {
      param = dot / lenSq;
    }

    double xx, yy;

    if (param < 0) {
      xx = lineStart.latitude;
      yy = lineStart.longitude;
    } else if (param > 1) {
      xx = lineEnd.latitude;
      yy = lineEnd.longitude;
    } else {
      xx = lineStart.latitude + param * C;
      yy = lineStart.longitude + param * D;
    }

    final double dx = point.latitude - xx;
    final double dy = point.longitude - yy;

    return sqrt(dx * dx + dy * dy) * 111.32; // Convert to kilometers
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });
    
    try {
      print('Loading reviews...'); // Debug log
      final reviewsSnapshot = await _firestore
          .collection('location_reviews')
          .orderBy('timestamp', descending: true)
          .get();

      print('Found ${reviewsSnapshot.docs.length} reviews'); // Debug log
      
      setState(() {
        _reviews = reviewsSnapshot.docs;
        _isLoadingReviews = false;
      });
    } catch (e) {
      print('Error loading reviews: $e'); // Debug log
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((item) => {
            'display_name': item['display_name'],
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
          }).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Error searching location: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      destinationLocation = point;
      _showRoute = true;
    });
    _getRoute();
    _loadReviews();
  }

  void _selectDestination(Map<String, dynamic> location) {
    final destination = LatLng(location['lat'], location['lon']);
    setState(() {
      selectedLocation = destination;
      _searchResults = [];
      _searchController.clear();
    });

    if (currentLocation != null) {
      _getRoute();
      _loadReviews();
    }
  }

  List<DocumentSnapshot> _getReviewsInRadius(LatLng start, LatLng end) {
    if (_routeCoordinates.isEmpty) return [];

    return _reviews.where((review) {
      final data = review.data() as Map<String, dynamic>;
      final reviewLocation = LatLng(
        data['latitude'].toDouble(),
        data['longitude'].toDouble(),
      );
      
      // Calculate distance from review to the route
      double minDistance = double.infinity;
      for (int i = 0; i < _routeCoordinates.length - 1; i++) {
        double distance = _distanceFromPointToLineSegment(
          reviewLocation,
          _routeCoordinates[i],
          _routeCoordinates[i + 1],
        );
        if (distance < minDistance) {
          minDistance = distance;
        }
      }
      
      return minDistance <= 5.0; // 5KM radius
    }).toList();
  }

  Future<void> _deleteReview(DocumentSnapshot review) async {
    final data = review.data() as Map<String, dynamic>;
    final currentUser = _auth.currentUser;

    if (currentUser == null || data['userId'] != currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotDeleteReview),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('location_reviews')
          .doc(review.id)
          .delete();
      
      setState(() {
        _reviews.remove(review);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reviewDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorDeletingReview),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getRoute() async {
    if (currentLocation == null || destinationLocation == null) return;

    try {
      final response = await http.get(Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${currentLocation!.longitude},${currentLocation!.latitude};${destinationLocation!.longitude},${destinationLocation!.latitude}?overview=full&geometries=geojson'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok') {
          setState(() {
            _routeCoordinates = (data['routes'][0]['geometry']['coordinates'] as List)
                .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
                .toList();
          });
          _loadReviews();
        }
      }
    } catch (e) {
      print('Error getting route: $e');
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _showReviewDetails(DocumentSnapshot review) {
    final data = review.data() as Map<String, dynamic>;
    final rating = data['rating'] as double;
    final reviewText = data['review'] as String? ?? '';
    final timestamp = data['timestamp'] as Timestamp;
    final userName = data['userName'] as String? ?? 'Anonymous';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text('Rating: ${rating.toStringAsFixed(1)}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By: $userName'),
            Text('Posted: ${DateFormat('MMM d, y HH:mm').format(timestamp.toDate())}'),
            SizedBox(height: 8),
            Text(reviewText),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            AppLocalizations.of(context)!.filterReviews,
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.minimumRating,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Slider(
                value: _minRating,
                min: 0,
                max: 5,
                divisions: 10,
                label: _minRating.toStringAsFixed(1),
                activeColor: isDark ? Colors.pinkAccent : Colors.pink,
                inactiveColor: isDark ? Colors.pinkAccent.withOpacity(0.3) : Colors.pink.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _minRating = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.maximumDistance,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Slider(
                value: _maxDistance,
                min: 1,
                max: 50,
                divisions: 49,
                label: '${_maxDistance.round()} km',
                activeColor: isDark ? Colors.pinkAccent : Colors.pink,
                inactiveColor: isDark ? Colors.pinkAccent.withOpacity(0.3) : Colors.pink.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _maxDistance = value;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.sortBy,
                  labelStyle: GoogleFonts.poppins(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.pinkAccent : Colors.pink,
                    ),
                  ),
                ),
                dropdownColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'timestamp',
                    child: Text(AppLocalizations.of(context)!.sortByDate),
                  ),
                  DropdownMenuItem(
                    value: 'rating',
                    child: Text(AppLocalizations.of(context)!.sortByRating),
                  ),
                  if (currentLocation != null)
                    DropdownMenuItem(
                      value: 'distance',
                      child: Text(AppLocalizations.of(context)!.sortByDistance),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _minRating = 0.0;
                  _maxDistance = 50.0;
                  _sortBy = 'timestamp';
                });
              },
              child: Text(
                AppLocalizations.of(context)!.reset,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadReviews();
              },
              child: Text(
                AppLocalizations.of(context)!.apply,
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.pinkAccent : Colors.pink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    final reviewsInRadius = (currentLocation != null && destinationLocation != null && _routeCoordinates.isNotEmpty)
        ? _getReviewsInRadius(currentLocation!, destinationLocation!)
        : <DocumentSnapshot>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.mapTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: localizations.filterReviews,
          ),
          if (destinationLocation != null)
            IconButton(
              icon: Icon(
                _showRoute ? Icons.route : Icons.route_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showRoute = !_showRoute;
                });
              },
              tooltip: _showRoute ? 'Hide Route' : 'Show Route',
            ),
          if (destinationLocation != null)
            IconButton(
              icon: Icon(Icons.star),
              onPressed: () {
                if (destinationLocation != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationReviewPage(
                        initialLocation: destinationLocation,
                      ),
                    ),
                  ).then((result) {
                    if (result == true) {
                      _loadReviews();
                    }
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error submitting review: ${error.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.selectLocation),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              tooltip: 'Add Review',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.pinkAccent : Colors.pink,
                ),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentLocation ?? LatLng(20.5937, 78.9629),
                    initialZoom: currentLocation != null ? 15.0 : 5.0,
                    keepAlive: true,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.womensafety.app',
                    ),
                    if (currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentLocation!,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    if (destinationLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: destinationLocation!,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    if (_showRoute && _routeCoordinates.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routeCoordinates,
                            color: Colors.blue,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    if (currentLocation != null && destinationLocation != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: currentLocation!,
                            radius: 5000, // 5KM in meters
                            color: Colors.pink.withOpacity(0.1),
                            borderColor: Colors.pink.withOpacity(0.3),
                            borderStrokeWidth: 2,
                          ),
                          CircleMarker(
                            point: destinationLocation!,
                            radius: 5000, // 5KM in meters
                            color: Colors.pink.withOpacity(0.1),
                            borderColor: Colors.pink.withOpacity(0.3),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: reviewsInRadius.map((review) {
                        final data = review.data() as Map<String, dynamic>;
                        final position = LatLng(
                          data['latitude'].toDouble(),
                          data['longitude'].toDouble(),
                        );
                        return Marker(
                          point: position,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showReviewDetails(review),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 30,
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.amber, width: 1),
                                    ),
                                    child: Text(
                                      data['rating'].toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (currentLocation != null) {
                _mapController.move(currentLocation!, 15.0);
              } else {
                _getCurrentLocation();
              }
            },
            backgroundColor: isDark ? Colors.pinkAccent : Colors.pink,
            child: Icon(
              Icons.my_location,
              color: Colors.white,
            ),
            heroTag: 'location',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              if (currentLocation != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationReviewPage(
                      initialLocation: currentLocation,
                    ),
                  ),
                ).then((value) {
                  if (value == true) {
                    _loadReviews();
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please wait for current location'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            backgroundColor: isDark ? Colors.pinkAccent : Colors.pink,
            child: Icon(
              Icons.add_comment,
              color: Colors.white,
            ),
            heroTag: 'add_review',
          ),
        ],
      ),
    );
  }
}
