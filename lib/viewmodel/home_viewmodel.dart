import 'package:flutter/material.dart';
import 'package:depd_mvvm_2025/model/model.dart';
import 'package:depd_mvvm_2025/data/response/api_response.dart';
import 'package:depd_mvvm_2025/data/response/status.dart';
import 'package:depd_mvvm_2025/repository/home_repository.dart';

class HomeViewModel with ChangeNotifier {
  final _homeRepo = HomeRepository();
  final Map<int, List<City>> _cityCache = {}; 

  ApiResponse<List<Province>> provinceList = ApiResponse.notStarted();
  setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  // Ambil daftar provinsi
  Future getProvinceList() async {
    if (provinceList.status == Status.completed) return;
    setProvinceList(ApiResponse.loading());
    _homeRepo.fetchProvinceList().then((value) {
      setProvinceList(ApiResponse.completed(value));
    }).onError((error, _) {
      setProvinceList(ApiResponse.error(error.toString()));
    });
  }

  // daftar kota asal
  ApiResponse<List<City>> cityOriginList = ApiResponse.notStarted();
  setCityOriginList(ApiResponse<List<City>> response) {
    cityOriginList = response;
    notifyListeners();
  }

  // daftar kota tujuan
  ApiResponse<List<City>> cityDestinationList = ApiResponse.notStarted();
  setCityDestinationList(ApiResponse<List<City>> response) {
    cityDestinationList = response;
    notifyListeners();
  }
  
  Future<List<City>> _fetchAndCacheCityList(int provinceId) async {
    if (_cityCache.containsKey(provinceId)) {
      return _cityCache[provinceId]!;
    }
    
    final cities = await _homeRepo.fetchCityList(provinceId);
    
    _cityCache[provinceId] = cities;
    return cities;
  }

  Future<void> getCityOriginList({required int provinceId}) async {
    // Jika sudah ada di cache, langsung set state dan return
    if (_cityCache.containsKey(provinceId)) {
      setCityOriginList(ApiResponse.completed(_cityCache[provinceId]!));
      return;
    }

    setCityOriginList(ApiResponse.loading());
    try {
      final value = await _fetchAndCacheCityList(provinceId);
      setCityOriginList(ApiResponse.completed(value));
    } catch (error) {
      setCityOriginList(ApiResponse.error(error.toString()));
    }
  }

  Future<void> getCityDestinationList({required int provinceId}) async {
    // Jika sudah ada di cache, langsung set state dan return
    if (_cityCache.containsKey(provinceId)) {
      setCityDestinationList(ApiResponse.completed(_cityCache[provinceId]!));
      return;
    }
    
    setCityDestinationList(ApiResponse.loading());
    try {
      final value = await _fetchAndCacheCityList(provinceId);
      setCityDestinationList(ApiResponse.completed(value));
    } catch (error) {
      setCityDestinationList(ApiResponse.error(error.toString()));
    }
  }
  
  // Biaya Ongkir
  ApiResponse<List<Costs>> costList = ApiResponse.notStarted();
  setCostList(ApiResponse<List<Costs>> response) {
    costList = response;
    notifyListeners();
  }

  // loading proses hitung ongkir
  bool isLoading = false;
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Hitung biaya pengiriman
  Future checkShipmentCost(
    String origin,
    String originType,
    String destination,
    String destinationType,
    int weight,
    String courier,
  ) async {
    setLoading(true);
    setCostList(ApiResponse.loading());
    _homeRepo
        .checkShipmentCost(
          origin,
          originType,
          destination,
          destinationType,
          weight,
          courier,
        )
        .then((value) {
          setCostList(ApiResponse.completed(value));
          setLoading(false);
        })
        .onError((error, _) {
          setCostList(ApiResponse.error(error.toString()));
          setLoading(false);
        });
  }
}