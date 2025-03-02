import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageContainer extends StatelessWidget {
  final Map<String, dynamic> salonData;
  final bool isFavorite;
  final Future<void> Function() onFavoriteToggle;
  final bool isLoading;

  const ImageContainer({
    Key? key,
    required this.salonData,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.isLoading = false,
  }) : super(key: key);

  Future<void> _launchPhone() async {
  print('Attempting to launch Phone');
  final phoneNumber = salonData['phone']?.toString() ?? '';
  print('Phone number: $phoneNumber');
  
  if (phoneNumber.isEmpty) {
    print('Phone number is empty');
    throw 'Phone number not available';
  }

  // Use tel: scheme with dial instead of direct launch
  final phoneUrl = 'tel:$phoneNumber';
  print('Phone URL: $phoneUrl');
  
  try {
    // Use launchUrl with specific mode
    final uri = Uri.parse(phoneUrl);
    if (await canLaunchUrl(uri)) {
      print('Launching phone URL');
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      print('Cannot launch phone URL');
      throw 'Could not launch phone';
    }
  } catch (e) {
    print('Error launching phone: $e');
    rethrow;
  }
}

Future<void> _launchWhatsApp() async {
  print('Attempting to launch WhatsApp');
  final phoneNumber = salonData['phone']?.toString() ?? '';
  print('Phone number: $phoneNumber');
  
  if (phoneNumber.isEmpty) {
    print('Phone number is empty');
    throw 'Phone number not available';
  }

  // Add country code if not present
  final cleanPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
  final whatsappUrl = 'whatsapp://send?phone=${cleanPhone.replaceAll(RegExp(r'[^\d+]'), '')}';
  print('WhatsApp URL: $whatsappUrl');

  try {
    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      print('Launching WhatsApp URL');
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Fallback to web WhatsApp
      final webUrl = 'https://wa.me/${cleanPhone.replaceAll(RegExp(r'[^\d+]'), '')}';
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(
          Uri.parse(webUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw "Could not launch WhatsApp";
      }
    }
  } catch (e) {
    print('Error launching WhatsApp: $e');
    rethrow;
  }
}

Future<void> _launchMap() async {
  print('Attempting to launch Map');
  
  // Get coordinates from salonData, checking both direct and nested paths
  final coordinates = salonData['coordinates'];
  double latitude;
  double longitude;
  
  // Handle coordinates based on data structure
  if (coordinates != null && coordinates is Map) {
    // Handle nested coordinates structure
    latitude = _parseCoordinate(coordinates['latitude']);
    longitude = _parseCoordinate(coordinates['longitude']);
  } else {
    // Handle flat structure
    latitude = _parseCoordinate(salonData['latitude']);
    longitude = _parseCoordinate(salonData['longitude']);
  }
  
  print('Coordinates: $latitude, $longitude');
  
  // Validate coordinates
  if (latitude == 0.0 || longitude == 0.0) {
    print('Invalid coordinates: $latitude, $longitude');
    throw 'Invalid coordinates';
  }
  
  final salonName = Uri.encodeComponent(salonData['name'] ?? '');
  final mapUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  print('Map URL: $mapUrl');
  
  try {
    final uri = Uri.parse(mapUrl);
    if (await canLaunchUrl(uri)) {
      print('Launching map URL');
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      print('Cannot launch map URL');
      throw 'Could not launch map';
    }
  } catch (e) {
    print('Error launching map: $e');
    rethrow;
  }
}

// Enhanced coordinate parsing
double _parseCoordinate(dynamic value) {
  if (value == null) return 0.0;
  
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      print('Error parsing coordinate: $e');
      return 0.0;
    }
  }
  
  print('Unexpected coordinate type: ${value.runtimeType}');
  return 0.0;
}
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Future<void> Function() onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        print('Action button tapped: $label'); // Debug print
        try {
          await onTap();
        } catch (e) {
          print('Error in action button: $e'); // Debug print
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unable to open $label: $e'), // Added error message
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 76, 255, 1),
              border: Border.all(color: Colors.black, width: 3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Rest of the widget implementation remains the same...
  @override
  Widget build(BuildContext context) {
    print('Building ImageContainer with data: $salonData');     return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black],
            ).createShader(bounds),
            blendMode: BlendMode.darken,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Image.network(
                salonData['shopUrl'] ?? '',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircularButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildFavoriteButton(context),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.phone,
                label: 'Call',
                onTap: _launchPhone,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                context: context,
                icon: Icons.message,
                label: 'Chat',
                onTap: _launchWhatsApp,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                context: context,
                icon: Icons.location_on,
                label: 'Map',
                onTap: _launchMap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Container(
      key: ValueKey<bool>(isFavorite),
      decoration: BoxDecoration(
        color: isFavorite ? Colors.red : Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isLoading
              ? null
              : () async {
                  try {
                    await onFavoriteToggle();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'Removed from favorites'
                                : 'Added to favorites',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update favorites'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.white : Colors.grey,
                      size: 24,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Colors.black,
      ),
    );
  }

  
}