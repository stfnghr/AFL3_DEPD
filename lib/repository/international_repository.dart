import 'package:depd_mvvm_2025/data/network/network_api_service.dart';
import 'package:depd_mvvm_2025/model/model.dart'; 
import 'package:depd_mvvm_2025/data/network/base_api_service.dart';

class InternationalRepository {
  final BaseApiServices _apiServices = NetworkApiServices(); 

  // Mengambil daftar negara (Internasional/Destination)  
  Future<List<Country>> fetchCountryList({String searchQuery = ''}) async {
    final searchParam = searchQuery.isNotEmpty ? searchQuery : ''; 
    
    final endpoint = 
        'destination/international-destination?search=$searchParam&limit=20'; 
    
    final response = await _apiServices.getApiResponse(endpoint);
    
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => Country.fromJson(e)).toList();
  }

  // Mengambil daftar provinsi (Domestik/Origin)
  Future<List<Province>> fetchProvinceList() async {
    final response = await _apiServices.getApiResponse('destination/province');

    // Validasi response meta
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    // Parse data provinsi
    final data = response['data'];
    if (data is! List) return [];

    // Ubah setiap item (Map) menjadi object Province
    return data.map((e) => Province.fromJson(e)).toList();
  }

  // Mengambil daftar kota berdasarkan ID provinsi
  Future<List<City>> fetchCityList({required int provinceId}) async { 
    final endpoint = 'destination/city/$provinceId'; 

    final response = await _apiServices.getApiResponse(
      endpoint,
    );

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }


    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => City.fromJson(e)).toList();
  }

  Future<List<Costs>> checkInternationalShipmentCost(
    String originId, 
    String destinationId, 
    int weight,
    String courier,
  ) async {
    final response = await _apiServices.postApiResponse(
      'calculate/international-cost', 
      {
        "origin": originId,
        "destination": destinationId, 
        "weight": weight.toString(),
        "courier": courier,
      },
    );

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => Costs.fromJson(e)).toList();
  }
}