import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeSlots extends StatefulWidget {
  final String opening;
  final String closing;
  final Function(String) onTimeSelected;
  final int totalDuration;
  final String salonId;
  final DateTime selectedDate;

  const TimeSlots({
    Key? key,
    required this.opening,
    required this.closing,
    required this.onTimeSelected,
    required this.totalDuration, 
    required this.salonId, 
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<TimeSlots> createState() => _TimeSlotsState();
}

class _TimeSlotsState extends State<TimeSlots> {
  String? selectedStartTime;
  List<String> selectedTimeSlots = [];
  List<String> timeSlots = [];
  List<String> bookedTimeSlots=[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTimeSlots();
  }

  Future<void> _initializeTimeSlots() async {
    if (!mounted) return;  // Early exit if widget is already disposed
    await fetchBookedSlots();  
    if (!mounted) return;  // Check again after async operation
    generateTimeSlots();       
    if (mounted) {  // Check before setState
      setState(() => isLoading = false);
    }
  }


    @override
  void didUpdateWidget(TimeSlots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _initializeTimeSlots();
    }
  }





  Future<void> fetchBookedSlots() async {
    try {
      if (!mounted) return;  // Early exit if widget is already disposed
      
      if (widget.salonId.isEmpty) {
        print('Error: Invalid salon ID');
        return;
      }

      final startOfDay = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final appointments = await FirebaseFirestore.instance
          .collection('appointments')
          .where('salonId', isEqualTo: widget.salonId)
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(endOfDay))
          .where('bookingStatus', isEqualTo: 'confirmed')
          .get();

      // Check if mounted before updating state
      if (mounted) {
        setState(() {
          bookedTimeSlots.clear();
          for (var doc in appointments.docs) {
            final timeSlot = doc.data()['timeSlot'] as String;
            if (timeSlot.contains(' - ')) {
              final parts = timeSlot.split(' - ');
              markRangeAsBooked(parts[0], parts[1]);
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching booked slots: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading booked slots: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

 
 void markRangeAsBooked(String startTime, String endTime) {
    try {
      DateTime start = _parseTime(startTime);
      DateTime end = _parseTime(endTime);
      
      var current = start;
      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        bookedTimeSlots.add(_formatTimeIn12Hour(current));
        current = current.add(const Duration(minutes: 30));
      }
    } catch (e) {
      print('Error marking range as booked: $e');
    }
  }


  // Update the isSlotSelectable method to check for booked slots
  bool isSlotSelectable(String timeSlot) {
    if (widget.totalDuration == 0) return true;
    if (timeSlot == timeSlots.last) return false;
    if (bookedTimeSlots.contains(timeSlot)) return false;
    
    // Also check if any slot in the required duration is booked
    int slotIndex = timeSlots.indexOf(timeSlot);
    int slotsNeeded = (widget.totalDuration / 30).ceil();
    
    for (int i = 0; i <= slotsNeeded; i++) {
      if (slotIndex + i >= timeSlots.length) return false;
      String currentSlot = timeSlots[slotIndex + i];
      if (bookedTimeSlots.contains(currentSlot)) return false;
    }
    
    return (slotIndex + slotsNeeded) < timeSlots.length;
  }


  void generateTimeSlots() {
    try {
      print('Generating slots from ${widget.opening} to ${widget.closing}');

      // Parse the times
      DateTime startTime = _parseTime(widget.opening);
      DateTime endTime = _parseTime(widget.closing);

      timeSlots.clear();
      var currentSlot = startTime;
      
      // Generate slots until we reach the closing time
      while (currentSlot.compareTo(endTime) <= 0) {  // Using compareTo instead of <=
        timeSlots.add(_formatTimeIn12Hour(currentSlot));
        currentSlot = currentSlot.add(const Duration(minutes: 30));
      }
      
      print('Generated time slots: $timeSlots');
      print('Closing time (disabled): ${timeSlots.last}');

    } catch (e) {
      print('Error generating time slots: $e');
      _generateDefaultTimeSlots();
    }
  }

  DateTime _parseTime(String timeStr) {
    // Remove any quotes and extra spaces
    timeStr = timeStr.replaceAll('"', '').trim();
    
    // Split time and period
    List<String> parts = timeStr.split(' ');
    String time = parts[0];
    String period = parts[1]; // AM or PM
    
    // Split hours and minutes
    List<String> timeParts = time.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    
    // Convert to 24-hour format for internal calculations
    if (period.toUpperCase() == 'PM' && hours != 12) {
      hours += 12;
    } else if (period.toUpperCase() == 'AM' && hours == 12) {
      hours = 0;
    }
    
    return DateTime.now().copyWith(
      hour: hours,
      minute: minutes,
      second: 0,
      millisecond: 0,
    );
  }

  String _formatTimeIn12Hour(DateTime time) {
    int hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    
    // Convert to 12-hour format
    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }
    
    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _generateDefaultTimeSlots() {
    timeSlots.clear();
    var current = DateTime.now().copyWith(hour: 9, minute: 0);
    final end = DateTime.now().copyWith(hour: 18, minute: 0);
    
    // Generate slots until we reach the closing time
    while (current.compareTo(end) <= 0) {  // Using compareTo instead of <=
      timeSlots.add(_formatTimeIn12Hour(current));
      current = current.add(const Duration(minutes: 30));
    }
  }

    void selectTimeRange(String startTime, BuildContext context) {
    if (widget.totalDuration == 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Services',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          content: Text(
              'Please select services to book time slots.',
              style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.montserrat()),
            ),
          ],
        ),
      );
      return;
    }

    // Check if mounted before setState
    if (!mounted) return;
    
    setState(() {
      selectedStartTime = startTime;
      selectedTimeSlots.clear();
      
      // Find the index of the selected start time
      int startIndex = timeSlots.indexOf(startTime);
      if (startIndex == -1) return;

      // Calculate how many 30-minute slots we need
      int slotsNeeded = widget.totalDuration <= 30 ? 0 : (widget.totalDuration / 30).ceil() - 1;

      print('Total duration: ${widget.totalDuration} minutes');
      print('Slots needed: $slotsNeeded');
      
      // Check if we have enough slots available
      if (startIndex + slotsNeeded >= timeSlots.length) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Invalid Time Selection',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            content: Text(
                'Selected time slot cannot accommodate the service duration of ${widget.totalDuration} minutes. Please select an earlier time.',
                style: GoogleFonts.montserrat()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: GoogleFonts.montserrat()),
              ),
            ],
          ),
        );
        return;
      }

      // Add all slots needed to cover the duration (including end time)
      for (int i = 0; i <= slotsNeeded; i++) {  // Changed < to <= to include end slot
        if (startIndex + i < timeSlots.length) {
          String slotToAdd = timeSlots[startIndex + i];
          selectedTimeSlots.add(slotToAdd);
          print('Added slot: $slotToAdd');
        }
      }

      print('Selected time slots: $selectedTimeSlots');

      // Notify parent with the time range
      if (selectedTimeSlots.isNotEmpty) {
        // Get the last slot for the end time
        String endTime = selectedTimeSlots.last;
        String timeRange = "$startTime - $endTime";
        widget.onTimeSelected(timeRange);
        print('Time range selected: $timeRange');
      }
    });
  }


   bool isSlotSelected(String timeSlot) {
    return selectedTimeSlots.contains(timeSlot);
  }

bool isSlotInSelectedRange(String timeSlot) {
    if (selectedStartTime == null) return false;
    
    int startIndex = timeSlots.indexOf(selectedStartTime!);
    int currentIndex = timeSlots.indexOf(timeSlot);
    
    // For 30-minute duration, only highlight the selected slot
    if (widget.totalDuration <= 30) {
      return currentIndex == startIndex;
    }
    
    // For longer durations, highlight the range
    int slotsNeeded = (widget.totalDuration / 30).ceil() - 1;
    return currentIndex >= startIndex && currentIndex <= (startIndex + slotsNeeded);
  }


  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) {
      return const Center(child: Text('No time slots available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Time",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.totalDuration > 0) ...[
          const SizedBox(height: 8),
          Text(
            "Please select a ${widget.totalDuration} minutes time slot",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final timeSlot = timeSlots[index];
            final isSelected = isSlotInSelectedRange(timeSlot);
            final isClosingTime = timeSlot == timeSlots.last;
            final canSelect = isSlotSelectable(timeSlot);
            
            return InkWell(
              onTap: canSelect ? () => selectTimeRange(timeSlot, context) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF004CFF)
                      : isClosingTime
                          ? Colors.grey[300]  // Different color for closing time
                          : canSelect 
                              ? Colors.white
                              : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF004CFF)
                        : Colors.grey[400]!,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  timeSlot,
                  style: GoogleFonts.montserrat(
                    color: isSelected
                        ? Colors.white
                        : isClosingTime
                            ? Colors.grey[600]  // Different text color for closing time
                            : canSelect
                                ? Colors.black
                                : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}