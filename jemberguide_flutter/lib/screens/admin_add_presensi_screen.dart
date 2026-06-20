import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/presensi_provider.dart';
import '../providers/jember_provider.dart';

class AdminAddPresensiScreen extends StatefulWidget {
  const AdminAddPresensiScreen({super.key});

  @override
  State<AdminAddPresensiScreen> createState() => _AdminAddPresensiScreenState();
}

class _AdminAddPresensiScreenState extends State<AdminAddPresensiScreen> {
  String? _targetUsername;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedStatus = 'Tepat Waktu';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JemberProvider>(context, listen: false).loadAllUsers();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_targetUsername == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        _targetUsername = args;
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PresensiProvider>(context);
    final jemberProvider = Provider.of<JemberProvider>(context);

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Presensi Manual', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_targetUsername != null && ModalRoute.of(context)?.settings.arguments != null)
                Text(
                  'User: $_targetUsername',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              else
                DropdownButtonFormField<String>(
                  value: _targetUsername,
                  decoration: InputDecoration(
                    labelText: 'Pilih User',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: jemberProvider.allUsers.map((u) {
                    return DropdownMenuItem(
                      value: u.username,
                      child: Text('${u.fullName} (@${u.username})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _targetUsername = val;
                    });
                  },
                ),
              const SizedBox(height: 24),

              ListTile(
                title: const Text('Tanggal Presensi'),
                subtitle: Text(dateStr),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              ListTile(
                title: const Text('Waktu Presensi'),
                subtitle: Text(timeStr),
                trailing: const Icon(Icons.access_time),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: _pickTime,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status Kehadiran',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Tepat Waktu', 'Terlambat'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedStatus = val);
                  }
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: (provider.isLoading || _targetUsername == null)
                    ? null
                    : () async {
                        await provider.catatPresensiManual(
                          targetUsername: _targetUsername!,
                          date: dateStr,
                          time: timeStr,
                          status: _selectedStatus,
                        );

                        if (provider.errorMessage != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.errorMessage!)),
                            );
                            provider.clearMessages();
                          }
                        } else if (provider.successMessage != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.successMessage!)),
                            );
                            provider.clearMessages();
                            Navigator.pop(context);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFE57E22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: provider.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Simpan Presensi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
