import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/presensi_provider.dart';
import '../providers/jember_provider.dart';

class HistoriPresensiScreen extends StatefulWidget {
  const HistoriPresensiScreen({super.key});

  @override
  State<HistoriPresensiScreen> createState() => _HistoriPresensiScreenState();
}

class _HistoriPresensiScreenState extends State<HistoriPresensiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<JemberProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<PresensiProvider>(context, listen: false).loadHistori(user.username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final presensiProvider = Provider.of<PresensiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histori Presensi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: presensiProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : presensiProvider.historiPresensi.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada data presensi.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: presensiProvider.historiPresensi.length,
                  itemBuilder: (context, index) {
                    final presensi = presensiProvider.historiPresensi[index];
                    final isLate = presensi.status == "Terlambat";
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLate ? Colors.red.shade100 : Colors.green.shade100,
                          child: Icon(
                            isLate ? Icons.timer_off : Icons.timer,
                            color: isLate ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Text('${presensi.date} - ${presensi.time}'),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                presensi.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isLate ? Colors.red : Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  presensi.status,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
