part of 'widgets.dart';

Widget _buildDetailRow({required String label, required String value}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100, 
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
        ),
        const Text(' : '), 
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left, 
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

void showCostDetailModal(
    BuildContext context, 
    Costs cost, 
    int? costValue, 
    String? etdValue, 
    String Function(int?) rupiahFormatter, 
    String Function(String?) etdFormatter
) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40), 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD), 
                    radius: 24,
                    child: Icon(Icons.local_shipping, color: Color(0xFF1976D2)), 
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${cost.name}", 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                        ),
                        Text(
                          '${cost.service}', 
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              
              const Divider(height: 30), 
              
              _buildDetailRow(label: 'Nama Kurir', value: '${cost.name}'), 
              _buildDetailRow(label: 'Kode', value: '${cost.code}'.toUpperCase()),
              _buildDetailRow(label: 'Layanan', value: '${cost.service}'), 
              _buildDetailRow(label: 'Deskripsi', value: '${cost.description}'),
              
              const SizedBox(height: 10), 
              
              _buildDetailRow(label: 'Biaya', value: rupiahFormatter(costValue)),
              _buildDetailRow(label: 'Estimasi Pengiriman', value: etdFormatter('${cost.etd}')),
            ],
          ),
        );
      },
    );
}

// InkWell
class CardCost extends StatefulWidget {
  final Costs cost;
  const CardCost(this.cost, {super.key});

  @override
  State<CardCost> createState() => _CardCostState();
}

class _CardCostState extends State<CardCost> {
  String rupiahMoneyFormatter(int? value) {
    if (value == null || value == 0) return "Rp0";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2, 
    );
    return formatter.format(value);
  }

  String formatEtd(String? etd) {
    if (etd == null || etd.isEmpty) return '-';
    final cleanedEtd = etd.replaceAll(RegExp(r'[^0-9]'), ''); 
    return '$cleanedEtd hari'; 
  }

  @override
  Widget build(BuildContext context) {
    Costs costData = widget.cost;
    final int? costValue = costData.cost as int?;
    final String? etdValue = costData.etd;

    return InkWell( 
      onTap: () {
        showCostDetailModal(
          context, 
          costData,
          costValue, 
          etdValue,  
          rupiahMoneyFormatter, 
          formatEtd, 
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue[800]!),
        ),
        margin: const EdgeInsetsDirectional.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        color: Colors.white,
        child: ListTile(
          title: Text(
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.w700,
            ),
            "${costData.name}: ${costData.service}",
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                "Biaya: ${rupiahMoneyFormatter(costValue)}",
              ),
              const SizedBox(height: 4),
              Text(
                style: TextStyle(color: Colors.green[800]),
                "Estimasi sampai: ${formatEtd(etdValue)}",
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(Icons.local_shipping, color: Colors.blue[800]),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey), 
        ),
      ),
    );
  }
}