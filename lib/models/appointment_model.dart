import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sec_pro/models/service_model.dart';

class AppointmentModel {
  final String id;
  final String userId;
  final String salonId;
  final DateTime appointmentDate;
  final String timeSlot;
  final List<ServiceModel> services;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String paymentIntentId;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.salonId,
    required this.appointmentDate,
    required this.timeSlot,
    required this.services,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentIntentId,
    required this.createdAt,
  });

  factory AppointmentModel.fromFirestore(Map<String, dynamic> data) {
    return AppointmentModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      salonId: data['salonId'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      services: (data['services'] as List?)
          ?.map((s) => ServiceModel.fromMap(s))
          .toList() ?? [],
      totalAmount: double.parse(data['totalAmount'].toString()),
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      paymentIntentId: data['paymentIntentId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'salonId': salonId,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'services': services.map((s) => s.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentIntentId': paymentIntentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 