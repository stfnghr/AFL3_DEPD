// lib/model/country.dart

part of 'model.dart';

class Country extends Equatable {
  final int? countryId; 
  final String? countryName;

  const Country({this.countryId, this.countryName});

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    countryId: int.tryParse(json['country_id'].toString()),
    countryName: json['country_name'] as String?, 
  );

  @override
  List<Object?> get props => [countryId, countryName];
}