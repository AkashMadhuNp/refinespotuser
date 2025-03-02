import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sec_pro/screens/search/saloon_Detail/sample.dart';
import 'package:sec_pro/service/favorite/fav_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteSalonCard extends StatefulWidget {
  final Map<String, dynamic> salon;

  const FavoriteSalonCard({
    Key? key,
    required this.salon,
  }) : super(key: key);

  @override
  State<FavoriteSalonCard> createState() => _FavoriteSalonCardState();
}

class _FavoriteSalonCardState extends State<FavoriteSalonCard> {
  final FavoritesService _favoritesService = FavoritesService();
  double avgRating = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAverageRating();
  }

  Future<void> _fetchAverageRating() async {
    try {
      final salonId = widget.salon['salonId'] ?? widget.salon['uid'];
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('review')
          .where('salonId', isEqualTo: salonId)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          avgRating = 0;
          isLoading = false;
        });
        return;
      }
      
      double totalRating = 0;
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final rating = (data['rating'] ?? 0).toDouble();
        totalRating += rating;
      }
      
      setState(() {
        avgRating = totalRating / querySnapshot.docs.length;
        isLoading = false;
      });
    } catch (e) {
      print('Error calculating average rating: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(BuildContext context) async {
    final bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Remove from Favorites',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to remove this salon from your favorites?',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Remove',
                style: GoogleFonts.montserrat(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      try {
        final salonId = widget.salon['salonId'] ?? widget.salon['uid'];
        await _favoritesService.removeFromFavorites(salonId);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Removed from favorites',
                style: GoogleFonts.montserrat(),
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to remove from favorites',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  void _navigateToSalonDetail(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SampleDetail(salonData: widget.salon)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _navigateToSalonDetail(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSalonImage(),
              _buildSalonDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalonImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          child: Image.network(
            widget.salon['shopUrl'] ?? widget.salon['profileUrl'] ?? '',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                color: Colors.grey[100],
                child: Icon(Icons.store, size: 50, color: Colors.grey[400]),
              );
            },
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFFFFD700),
                  size: 16,
                ),
                const SizedBox(width: 4),
                isLoading
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black54,
                        ),
                      )
                    : Text(
                        avgRating.toStringAsFixed(1),
                        style: GoogleFonts.montserrat(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalonDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.salon['salonName'] ?? widget.salon['name'] ?? 'Unknown Salon',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _removeFromFavorites(context),
                icon: const Icon(Icons.favorite),
                color: Colors.red,
                tooltip: 'Remove from favorites',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // View Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToSalonDetail(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View Details',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: color,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}