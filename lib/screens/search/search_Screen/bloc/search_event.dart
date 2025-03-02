import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class ToggleFiltersEvent extends SearchEvent {}

class ServiceFilterChanged extends SearchEvent {
  final String? service;

  const ServiceFilterChanged(this.service);

  @override
  List<Object?> get props => [service];
}

class PriceRangeChanged extends SearchEvent {
  final double start;
  final double end;

  const PriceRangeChanged(this.start, this.end);

  @override
  List<Object> get props => [start, end];
}

class ResetFiltersEvent extends SearchEvent {}

class ResetAllFiltersEvent extends SearchEvent {}

class FetchServicesEvent extends SearchEvent {}
