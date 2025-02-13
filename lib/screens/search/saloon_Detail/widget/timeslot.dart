// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class TimeSlots extends StatefulWidget {
//   final String workingHours;
//   final Function(String) onTimeSelected;

//   const TimeSlots({
//     Key? key,
//     required this.workingHours,
//     required this.onTimeSelected,
//   }) : super(key: key);

//   @override
//   State<TimeSlots> createState() => _TimeSlotsState();
// }

// class _TimeSlotsState extends State<TimeSlots> {
//   String? selectedTime;
//   List<String> timeSlots = [];

//   @override
//   void initState() {
//     super.initState();
//     generateTimeSlots();
//   }

//   void generateTimeSlots() {
    
//     print('Working Hours: ${widget.workingHours}');

    
//     DateTime startTime = DateTime.now().copyWith(hour: 8, minute: 0);
//     DateTime endTime = DateTime.now().copyWith(hour: 23, minute: 59);

//     try {
      
//       final parts = widget.workingHours.split('-');
//       if (parts.length == 2) {
//         final startParts = parts[0].trim().split(' ');
//         final endParts = parts[1].trim().split(' ');

//         if (startParts.length >= 2 && endParts.length >= 2) {
//           // Parse start time
//           final startTimeParts = startParts[0].split(':');
//           int startHour = int.parse(startTimeParts[0]);
//           int startMinute = int.parse(startTimeParts[1]);
//           if (startParts[1] == 'PM' && startHour != 12) startHour += 12;
//           if (startParts[1] == 'AM' && startHour == 12) startHour = 0;

//           // Parse end time
//           final endTimeParts = endParts[0].split(':');
//           int endHour = int.parse(endTimeParts[0]);
//           int endMinute = int.parse(endTimeParts[1]);
//           if (endParts[1] == 'PM' && endHour != 12) endHour += 12;
//           if (endParts[1] == 'AM' && endHour == 12) endHour = 0;

//           startTime = DateTime.now().copyWith(hour: startHour, minute: startMinute);
//           endTime = DateTime.now().copyWith(hour: endHour, minute: endMinute);
//         }
//       }
//     } catch (e) {
//       print('Error parsing time: $e');
//     }

  
//     timeSlots.clear();
//     DateTime currentSlot = startTime;
    
//     while (currentSlot.isBefore(endTime) || 
//            (currentSlot.hour == endTime.hour && currentSlot.minute <= endTime.minute)) {
//       timeSlots.add(_formatTime(currentSlot));
//       currentSlot = currentSlot.add(const Duration(minutes: 30));
//     }

//     // Print generated slots for debugging
//     print('Generated ${timeSlots.length} time slots');
//     print('First slot: ${timeSlots.first}');
//     print('Last slot: ${timeSlots.last}');
//   }

//   String _formatTime(DateTime time) {
//     final hour = time.hour;
//     final minute = time.minute;
//     final period = hour >= 12 ? 'PM' : 'AM';
//     final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
//     return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (timeSlots.isEmpty) {
//       return const Center(child: Text('No time slots available'));
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Select Time",
//           style: GoogleFonts.montserrat(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 16),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 4,
//             childAspectRatio: 2.5,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 8,
//           ),
//           itemCount: timeSlots.length,
//           itemBuilder: (context, index) {
//             final timeSlot = timeSlots[index];
//             final isSelected = selectedTime == timeSlot;
            
//             return InkWell(
//               onTap: () {
//                 setState(() {
//                   selectedTime = timeSlot;
//                 });
//                 widget.onTimeSelected(timeSlot);
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: isSelected ? const Color(0xFF004CFF) : Colors.grey[800],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: isSelected ? const Color(0xFF004CFF) : Colors.grey[600]!,
//                     width: 1,
//                   ),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   timeSlot,
//                   style: GoogleFonts.montserrat(
//                     color: isSelected ? Colors.white : Colors.grey[300],
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }