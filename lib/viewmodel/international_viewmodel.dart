// lib/viewmodel/international_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:depd_mvvm_2025/model/model.dart';
import 'package:depd_mvvm_2025/data/response/api_response.dart';
import 'package:depd_mvvm_2025/data/response/status.dart';
import 'package:depd_mvvm_2025/repository/international_repository.dart';

class InternationalViewModel with ChangeNotifier {
  final _internationalRepo = InternationalRepository();
  
  ApiResponse<List<Province>> provinceListOrigin = ApiResponse.notStarted();
  setProvinceListOrigin(ApiResponse<List<Province>> response) {
    provinceListOrigin = response;
    notifyListeners();
  }

  final Map<int, List<City>> _cityCache = {};
  
  // State daftar kota asal (Origin)
  ApiResponse<List<City>> cityOriginList = ApiResponse.notStarted();
  setCityOriginList(ApiResponse<List<City>> response) {
    cityOriginList = response;
    notifyListeners();
  }

  // Ambil daftar provinsi (Origin)
  Future<void> getProvinceListOrigin() async {
    if (provinceListOrigin.status == Status.completed) return;
    setProvinceListOrigin(ApiResponse.loading());
    _internationalRepo
        .fetchProvinceList() // Menggunakan InternationalRepo
        .then((value) => setProvinceListOrigin(ApiResponse.completed(value)))
        .onError((error, stack) => setProvinceListOrigin(ApiResponse.error(error.toString())));
  }

  // Ambil kota asal (Origin)
  Future<void> getCityOriginList({required int provinceId}) async {
    if (_cityCache.containsKey(provinceId)) {
      setCityOriginList(ApiResponse.completed(_cityCache[provinceId]!));
      return;
    }
    setCityOriginList(ApiResponse.loading());
    _internationalRepo
        .fetchCityList(provinceId: provinceId) 
        .then((value) {
          _cityCache[provinceId] = value;
          setCityOriginList(ApiResponse.completed(value));
        })
        .onError((error, stack) => setCityOriginList(ApiResponse.error(error.toString())));
  }

  // State daftar negara (Destination)
  ApiResponse<List<Country>> countryList = ApiResponse.notStarted();
  setCountryList(ApiResponse<List<Country>> response) { 
    countryList = response; 
    notifyListeners(); 
  }
  
  // Ambil daftar negara (Destination)
  Future<void> getCountryList({String? searchQuery}) async {
    setCountryList(ApiResponse.loading());
    _internationalRepo
        .fetchCountryList(searchQuery: searchQuery ?? '')
        .then((value) => setCountryList(ApiResponse.completed(value)))
        .onError((error, stack) => setCountryList(ApiResponse.error(error.toString())));
  }

  // State daftar biaya ongkir Internasional
  ApiResponse<List<Costs>> internationalCostList = ApiResponse.notStarted();
  setInternationalCostList(ApiResponse<List<Costs>> response) { 
    internationalCostList = response; 
    notifyListeners(); 
  }

  // Flag loading
  bool isLoading = false;
  void setLoading(bool value) { 
    isLoading = value; 
    notifyListeners(); 
  }

  // Hitung biaya pengiriman internasional
  Future<void> checkShipmentCost(
    String originId, 
    String destinationId, 
    int weight,
    String courier,
  ) async {
    setLoading(true);
    setInternationalCostList(ApiResponse.loading());
    _internationalRepo
        .checkInternationalShipmentCost(
          originId,
          destinationId, 
          weight,
          courier,
        )
        .then((value) {
          setInternationalCostList(ApiResponse.completed(value));
        })
        .onError((error, stack) {
          setInternationalCostList(ApiResponse.error(error.toString()));
        })
        .whenComplete(() => setLoading(false));
  }
}