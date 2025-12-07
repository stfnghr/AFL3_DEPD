part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeViewModel homeViewModel;
  final weightController = TextEditingController();
  final List<String> courierOptions = ["jne", "pos", "tiki", "lion", "sicepat"];
  String selectedCourier = "jne";
  int? selectedProvinceOriginId;
  int? selectedCityOriginId;
  int? selectedProvinceDestinationId;
  int? selectedCityDestinationId;

  @override
  void initState() {
    super.initState();
    homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    if (homeViewModel.provinceList.status == Status.notStarted) {
      homeViewModel.getProvinceList();
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cek Ongkir Domestik"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Card Form Input
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // ... (Dropdown Kurir & Berat) ...
                        Row(
                          children: [
                            Expanded(child: DropdownButton<String>(isExpanded: true, value: selectedCourier, items: courierOptions.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(), onChanged: (v) => setState(() => selectedCourier = v ?? "jne"))),
                            const SizedBox(width: 16),
                            Expanded(child: TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Berat (gr)'))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Origin
                        const Align(alignment: Alignment.centerLeft, child: Text("Origin", style: TextStyle(fontWeight: FontWeight.bold))),
                        Row(
                          children: [
                            // Dropdown provinsi asal
                            Expanded(
                              child: Consumer<HomeViewModel>(
                                builder: (context, vm, _) {
                                  // ... (Logika status loading/error/data) ...
                                  final provinces = vm.provinceList.data ?? [];
                                  if (vm.provinceList.status == Status.loading) {return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(color: Colors.black)));}
                                  if (vm.provinceList.status == Status.error) {return Text(vm.provinceList.message ?? 'Error', style: const TextStyle(color: Colors.red));}

                                  return DropdownButton<int>(
                                    isExpanded: true,
                                    value: selectedProvinceOriginId,
                                    hint: const Text('Pilih provinsi'),
                                    items: provinces.map((p) => DropdownMenuItem<int>(value: p.id, child: Text(p.name ?? ''))).toList(),
                                    onChanged: (newId) {
                                      setState(() {
                                        selectedProvinceOriginId = newId;
                                        selectedCityOriginId = null;
                                      });
                                      // 🎯 KOREKSI #1: Menggunakan named argument 'provinceId:'
                                      if (newId != null) { vm.getCityOriginList(provinceId: newId); }
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Dropdown kota asal
                            Expanded(
                              child: Consumer<HomeViewModel>(
                                builder: (context, vm, _) {
                                  // ... (Logika status kota) ...
                                  if (vm.cityOriginList.status == Status.notStarted) {return const Text('Pilih provinsi dulu', style: TextStyle(fontSize: 12, color: Colors.grey));}
                                  if (vm.cityOriginList.status == Status.loading) {return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(color: Colors.black)));}
                                  if (vm.cityOriginList.status == Status.error) {return Text(vm.cityOriginList.message ?? 'Error', style: const TextStyle(color: Colors.red));}

                                  if (vm.cityOriginList.status == Status.completed) {
                                    final cities = vm.cityOriginList.data ?? [];
                                    final validIds = cities.map((c) => c.id).toSet();
                                    final validValue = validIds.contains(selectedCityOriginId) ? selectedCityOriginId : null;

                                    return DropdownButton<int>(isExpanded: true, value: validValue, hint: const Text('Pilih kota'), items: cities.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name ?? ''))).toList(), onChanged: (newId) {setState(() {selectedCityOriginId = newId;});});
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Destination
                        const Align(alignment: Alignment.centerLeft, child: Text("Destination", style: TextStyle(fontWeight: FontWeight.bold))),
                        Row(
                          children: [
                            // Dropdown provinsi tujuan
                            Expanded(
                              child: Consumer<HomeViewModel>(
                                builder: (context, vm, _) {
                                  // ... (Logika status loading/error/data) ...
                                  final provinces = vm.provinceList.data ?? [];
                                  if (vm.provinceList.status == Status.loading) {return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(color: Colors.black)));}
                                  if (vm.provinceList.status == Status.error) {return Text(vm.provinceList.message ?? 'Error', style: const TextStyle(color: Colors.red, fontSize: 12));}

                                  return DropdownButton<int>(
                                    isExpanded: true,
                                    value: selectedProvinceDestinationId,
                                    hint: const Text('Pilih provinsi'),
                                    items: provinces.map((p) => DropdownMenuItem<int>(value: p.id, child: Text(p.name ?? ''))).toList(),
                                    onChanged: (newId) {
                                      setState(() {
                                        selectedProvinceDestinationId = newId;
                                        selectedCityDestinationId = null;
                                      });
                                      if (newId != null) { vm.getCityDestinationList(provinceId: newId); }
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Dropdown kota tujuan
                            Expanded(
                              child: Consumer<HomeViewModel>(
                                builder: (context, vm, _) {
                                  // ... (Logika status kota) ...
                                  if (vm.cityDestinationList.status == Status.notStarted) {return const Text('Pilih provinsi dulu', style: TextStyle(fontSize: 12, color: Colors.grey));}
                                  if (vm.cityDestinationList.status == Status.loading) {return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(color: Colors.black)));}
                                  if (vm.cityDestinationList.status == Status.error) {return Text(vm.cityDestinationList.message ?? 'Error', style: const TextStyle(color: Colors.red, fontSize: 12));}

                                  if (vm.cityDestinationList.status == Status.completed) {
                                    final cities = vm.cityDestinationList.data ?? [];
                                    final validIds = cities.map((c) => c.id).toSet();
                                    final validValue = validIds.contains(selectedCityDestinationId) ? selectedCityDestinationId : null;

                                    return DropdownButton<int>(isExpanded: true, value: validValue, hint: const Text('Pilih kota'), items: cities.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name ?? ''))).toList(), onChanged: (newId) {setState(() {selectedCityDestinationId = newId;});});
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Tombol Hitung
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedCityOriginId != null && selectedCityDestinationId != null && weightController.text.isNotEmpty && selectedCourier.isNotEmpty) {
                                final weight = int.tryParse(weightController.text) ?? 0;
                                if (weight <= 0) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berat harus lebih dari 0'), backgroundColor: Colors.redAccent)); return;}
                                homeViewModel.checkShipmentCost(selectedCityOriginId!.toString(), "city", selectedCityDestinationId!.toString(), "city", weight, selectedCourier);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua field!'), backgroundColor: Colors.redAccent));
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(16)),
                            child: const Text("Hitung Ongkir", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Card Hasil Ongkir
                Card(
                  color: Colors.blue[50],
                  elevation: 2,
                  child: Consumer<HomeViewModel>(
                    builder: (context, vm, _) {
                      switch (vm.costList.status) {
                        case Status.loading: return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator(color: Colors.black)));
                        case Status.error: return Padding(padding: const EdgeInsets.all(16.0), child: Center(child: Text(vm.costList.message ?? 'Error', style: const TextStyle(color: Colors.red))));
                        case Status.completed:
                          if (vm.costList.data == null || vm.costList.data!.isEmpty) {return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text("Tidak ada data ongkir.")));}
                          // Memanggil CardCost yang sudah dilengkapi InkWell
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: vm.costList.data?.length ?? 0,
                            itemBuilder: (context, index) => CardCost(vm.costList.data!.elementAt(index)),
                          );
                        default: return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text("Pilih kota dan klik Hitung Ongkir terlebih dulu.", style: TextStyle(color: Colors.black))));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Overlay loading
          Consumer<HomeViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {return Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: Colors.white)));}
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}