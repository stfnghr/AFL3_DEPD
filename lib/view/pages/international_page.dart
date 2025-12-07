// lib/view/pages/international_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:depd_mvvm_2025/model/model.dart';
import 'package:depd_mvvm_2025/viewmodel/international_viewmodel.dart'; 
import 'package:depd_mvvm_2025/data/response/status.dart';
import 'package:depd_mvvm_2025/view/widgets/widgets.dart'; 

class InternationalPage extends StatefulWidget {
  const InternationalPage({super.key});

  @override
  State<InternationalPage> createState() => _InternationalPageState();
}

class _InternationalPageState extends State<InternationalPage> {
  
  late InternationalViewModel internationalVM;

  final weightController = TextEditingController();
  final destinationController = TextEditingController(); 

  final List<String> courierOptions = ["pos", "tiki"]; 
  String selectedCourier = "pos";

  // State untuk Destination (Negara)
  Country? selectedCountryDestination; 
  List<Country> searchResultCountries = []; 
  bool isSearching = false; 

  // State untuk Origin (Domestik)
  int? selectedProvinceOriginId; 
  int? selectedCityOriginId; 

  @override
  void initState() {
    super.initState();
    internationalVM = Provider.of<InternationalViewModel>(context, listen: false);

    // Muat data Provinsi Origin saat inisialisasi dari InternationalVM
    if (internationalVM.provinceListOrigin.status == Status.notStarted) {
      internationalVM.getProvinceListOrigin();
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    destinationController.dispose();
    super.dispose();
  }
  
  void _onSearchCountryPressed() {
    // ... (Logika pencarian negara)
    FocusScope.of(context).unfocus(); 
    final query = destinationController.text.trim();
    
    if (query.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan minimal 3 karakter untuk mencari negara.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      setState(() {
        searchResultCountries = []; 
        isSearching = false; 
      });
      return;
    }
    
    setState(() {
      isSearching = true; 
      selectedCountryDestination = null; 
    });
    internationalVM.getCountryList(searchQuery: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cek Ongkir Internasional"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Section pilihan kurir dan berat barang
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedCourier,
                                items: courierOptions
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(
                                  () => selectedCourier = v ?? "pos",
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Berat (gr)',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Section Origin (Asal pengiriman - Domestik)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Origin (Kota Asal Domestik)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Consumer menggunakan InternationalViewModel
                        Consumer<InternationalViewModel>(
                            builder: (context, vm, _) => _buildOriginDropdowns(vm),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Section Destination (Tujuan pengiriman - Internasional)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Destination (Negara Tujuan Internasional)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        
                        _buildDestinationSearch(), 
                        
                        const SizedBox(height: 12),
                        
                        // Tombol untuk menghitung ongkir
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _validateAndCheckCost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text(
                              "Hitung Ongkir Internasional",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildCostResultCard(),
              ],
            ),
          ),
          
          Consumer<InternationalViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // --- Widget Builders ---
  
  // Mengambil data Origin dari InternationalViewModel
  Widget _buildOriginDropdowns(InternationalViewModel vm) {
    // Logika pemilihan Provinsi dan Kota Domestik
    return Row(
      children: [
        // Dropdown Provinsi Asal (menggunakan InternationalViewModel.provinceListOrigin)
        Expanded(
          child: Builder( 
            builder: (context) {
              if (vm.provinceListOrigin.status == Status.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final provinces = vm.provinceListOrigin.data ?? [];
              
              // Safety: Konversi ID ke int?
              final mappedProvinces = provinces.map((p) {
                  final int? provinceId = int.tryParse(p.id.toString());
                  if (provinceId != null) {
                      return DropdownMenuItem<int>(
                          value: provinceId,
                          child: Text(p.name ?? 'Unknown Province'),
                      );
                  }
                  return null;
              }).whereType<DropdownMenuItem<int>>().toList();

              return DropdownButton<int>(
                isExpanded: true,
                value: selectedProvinceOriginId,
                hint: const Text('Pilih provinsi'),
                items: mappedProvinces,
                onChanged: (newId) {
                  setState(() {
                    selectedProvinceOriginId = newId;
                    selectedCityOriginId = null; 
                  });
                  if (newId != null) {
                      vm.getCityOriginList(provinceId: newId);
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        // Dropdown Kota Asal (menggunakan InternationalViewModel.cityOriginList)
        Expanded(
          child: Consumer<InternationalViewModel>( 
            builder: (context, cityVm, _) {
              if (cityVm.cityOriginList.status == Status.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (cityVm.cityOriginList.status == Status.notStarted) {
                return const Text('Pilih provinsi dulu', style: TextStyle(fontSize: 12, color: Colors.grey));
              }

              final cities = cityVm.cityOriginList.data ?? [];
              
              // Safety: Konversi ID ke int?
              final mappedCities = cities.map((c) {
                  final int? cityId = int.tryParse(c.id.toString());
                  if (cityId != null) {
                      return DropdownMenuItem<int>(
                          value: cityId,
                          child: Text(c.name ?? 'Unknown City'),
                      );
                  }
                  return null;
              }).whereType<DropdownMenuItem<int>>().toList();
              
              final validIds = mappedCities.map((item) => item.value).toSet();
              final validValue = validIds.contains(selectedCityOriginId) ? selectedCityOriginId : null;

              return DropdownButton<int>(
                isExpanded: true,
                value: validValue,
                hint: const Text('Pilih kota'),
                items: mappedCities,
                onChanged: (newId) => setState(() => selectedCityOriginId = newId),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationSearch() {
    // ... (Logika pencarian negara yang menggunakan InternationalViewModel.countryList)
    return Column(
      children: [
        TextField(
          controller: destinationController,
          decoration: InputDecoration(
            hintText: 'Cari negara (min 3 karakter)',
            suffixIcon: Consumer<InternationalViewModel>(
              builder: (context, vm, _) {
                final isLoading = vm.countryList.status == Status.loading;
                
                return IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      : const Icon(Icons.search),
                  onPressed: isLoading ? null : _onSearchCountryPressed, 
                );
              },
            ),
          ),
        ),
        Consumer<InternationalViewModel>(
          builder: (context, vm, _) {
            if (vm.countryList.status == Status.completed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(mounted && vm.countryList.data != searchResultCountries) {
                       setState(() {
                          searchResultCountries = vm.countryList.data ?? [];
                          isSearching = true;
                      });
                  }
              });
            }
            if (isSearching && searchResultCountries.isNotEmpty) {
              return Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: searchResultCountries.length,
                  itemBuilder: (context, index) {
                    final country = searchResultCountries[index];
                    return ListTile(
                      title: Text(country.countryName ?? 'Nama Negara Tidak Ada'),
                      trailing: selectedCountryDestination?.countryId == country.countryId
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        FocusScope.of(context).unfocus(); 
                        setState(() {
                          selectedCountryDestination = country;
                          destinationController.text = country.countryName ?? '';
                          searchResultCountries = []; 
                          isSearching = false; 
                        });
                      },
                    );
                  },
                ),
              );
            }
            if (isSearching && searchResultCountries.isEmpty && vm.countryList.status == Status.completed) {
                return const Padding(padding: EdgeInsets.all(8.0), child: Text('Tidak ada negara ditemukan.'));
            }
            return const SizedBox.shrink();
          },
        ),
        if (selectedCountryDestination != null) 
          Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Negara Tujuan Terpilih: ${selectedCountryDestination!.countryName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),),
      ],
    );
  }

  Widget _buildCostResultCard() {
    // ... (Logika hasil ongkir yang menggunakan InternationalViewModel.internationalCostList)
    return Card(
      color: Colors.blue[50],
      elevation: 2,
      child: Consumer<InternationalViewModel>(
        builder: (context, vm, _) {
          switch (vm.internationalCostList.status) {
            case Status.loading: return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()),);
            case Status.error: return Padding(padding: const EdgeInsets.all(16.0), child: Center(child: Text(vm.internationalCostList.message ?? 'Error', style: const TextStyle(color: Colors.red)),),);
            case Status.completed:
              final costs = vm.internationalCostList.data;
              if (costs == null || costs.isEmpty) { return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text("Tidak ada data ongkir internasional.")),);}
              return ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: costs.length, itemBuilder: (context, index) => CardCost(costs.elementAt(index)),);
            default: return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text("Pilih lokasi dan klik Hitung Ongkir Internasional.")),);
          }
        },
      ),
    );
  }
  
  void _validateAndCheckCost() {
    final weightText = weightController.text;
    final weight = int.tryParse(weightText) ?? 0;

    if (selectedCityOriginId == null ||
        selectedCountryDestination == null || 
        weightText.isEmpty ||
        selectedCourier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua field!'), backgroundColor: Colors.redAccent,));
      return;
    }
    if (weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berat harus lebih dari 0'), backgroundColor: Colors.redAccent,));
      return;
    }

    // Panggil checkShipmentCost dari InternationalViewModel
    internationalVM.checkShipmentCost(
      selectedCityOriginId!.toString(),
      selectedCountryDestination!.countryId.toString(),
      weight,
      selectedCourier,
    );
  }
}