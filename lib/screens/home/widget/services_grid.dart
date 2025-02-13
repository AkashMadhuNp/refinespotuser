import 'package:flutter/material.dart';
import 'package:sec_pro/model/homePageService/home_service.dart';
import 'package:sec_pro/screens/home/widget/service_grid_item.dart';

class ServicesGrid extends StatelessWidget {
  final List<HomeService> services;

  const ServicesGrid({
    Key? key,
    required this.services,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return ServiceGridItem(service: services[index]);
      },
    );
  }
} 