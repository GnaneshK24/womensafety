import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' show Point;

class LocationReviewPage extends StatefulWidget {
  final DocumentSnapshot? review;
  final LatLng? initialLocation;
  
  const LocationReviewPage({
    super.key,
    this.review,
    this.initialLocation,
  });

  @override
  State<LocationReviewPage> createState() => _LocationReviewPageState();
}

class _LocationReviewPageState extends State<LocationReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  double _rating = 0.0;
  bool _isUploading = false;
  bool _isLoading = false;
  Map<String, dynamic>? _reviewData;
  LatLng? _selectedLocation;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _reviewData = widget.review!.data() as Map<String, dynamic>;
      _rating = _reviewData!['rating']?.toDouble() ?? 0.0;
      _commentController.text = _reviewData!['review'] ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.review == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Add Review' : 'Review Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.initialLocation != null || _reviewData != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                    ),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: widget.initialLocation ?? LatLng(
                          _reviewData!['latitude'].toDouble(),
                          _reviewData!['longitude'].toDouble(),
                        ),
                        initialZoom: 15.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _selectedLocation = point;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.womensafety.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation ?? (widget.initialLocation ?? LatLng(
                                _reviewData!['latitude'].toDouble(),
                                _reviewData!['longitude'].toDouble(),
                              )),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                  final localPosition = renderBox.globalToLocal(details.globalPosition);
                                  final point = _mapController.camera.pointToLatLng(Point(
                                    localPosition.dx.toDouble(),
                                    localPosition.dy.toDouble(),
                                  ));
                                  setState(() {
                                    _selectedLocation = point;
                                  });
                                },
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.pinkAccent,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
                if (isEditing) ...[
                  Text(
                    'Rating',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a comment';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.pinkAccent : Colors.pink,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Submit Review',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      );
                    }),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _commentController.text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Posted by ${_reviewData?['userName'] ?? 'Anonymous'}',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  Text(
                    'on ${DateFormat('MMM d, y HH:mm').format((_reviewData?['timestamp'] as Timestamp).toDate())}',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedLocation == null && widget.initialLocation == null && _reviewData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      print('Current user ID: $userId'); // Debug log
      
      if (userId == null) {
        print('User not authenticated'); // Debug log
        throw Exception('Please log in to submit a review');
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      print('User document exists: ${userDoc.exists}'); // Debug log
      
      final userName = userDoc.data()?['name'] ?? 'Anonymous';
      print('User name: $userName'); // Debug log

      final reviewData = {
        'userId': userId,
        'userName': userName,
        'rating': _rating,
        'review': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': _selectedLocation?.latitude ?? widget.initialLocation?.latitude ?? _reviewData?['latitude'],
        'longitude': _selectedLocation?.longitude ?? widget.initialLocation?.longitude ?? _reviewData?['longitude'],
      };

      print('Review data: $reviewData'); // Debug log

      if (widget.review != null) {
        print('Updating existing review'); // Debug log
        await _firestore.collection('location_reviews').doc(widget.review!.id).update(reviewData);
      } else {
        print('Creating new review'); // Debug log
        await _firestore.collection('location_reviews').add(reviewData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      print('Error submitting review: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      if (mounted) {
        String errorMessage = 'Error submitting review';
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'Permission denied. Please check if you are logged in.';
        } else if (e.toString().contains('not-found')) {
          errorMessage = 'User profile not found. Please try logging in again.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
} 