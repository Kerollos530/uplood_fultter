import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_transit/models/station_model.dart';
import 'package:smart_transit/state/admin_providers.dart';
import 'package:smart_transit/widgets/station_label.dart'; // Reuse our badge widget!

class ManageStationsScreen extends ConsumerWidget {
  const ManageStationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(adminStationsProvider);
    final isLoading = ref.watch(adminLoadingProvider);

    ref.listen<String?>(adminErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Stations'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(color: Colors.white),
              )
            : null,
      ),
      body: IgnorePointer(
        ignoring: isLoading,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final station = stations[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.place,
                  color: station.isActive ? Colors.green : Colors.grey,
                ),
                title: StationLabel(
                  stationName: station.nameEn,
                  transportType: station.type.name.toUpperCase(),
                  lineName: station.lines.isNotEmpty
                      ? station.lines.first
                      : null,
                ),
                subtitle: Text(
                  station.isActive ? 'Active' : 'Disabled',
                  style: TextStyle(
                    color: station.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Switch(
                  value: station.isActive,
                  onChanged: (val) async {
                    await ref
                        .read(adminStationsProvider.notifier)
                        .toggleStationStatus(station.id);
                  },
                ),
                onTap: () => _showEditDialog(context, ref, station),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    StationModel station,
  ) {
    final nameCtrl = TextEditingController(text: station.nameEn);
    final lineCtrl = TextEditingController(
      text: station.lines.isNotEmpty ? station.lines.first : '',
    );
    TransitType selectedType = station.type;

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final isLoading = ref.watch(adminLoadingProvider);
          return AlertDialog(
            title: Text('Edit ${station.nameEn}'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Station Name (EN)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TransitType>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Transport Type',
                      ),
                      items: TransitType.values.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lineCtrl,
                      decoration: const InputDecoration(labelText: 'Line Name'),
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => context.pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final updated = StationModel(
                          id: station.id,
                          nameAr: station.nameAr,
                          nameEn: nameCtrl.text,
                          type: selectedType,
                          latitude: station.latitude,
                          longitude: station.longitude,
                          lines: [lineCtrl.text],
                          isActive: station.isActive,
                        );

                        await ref
                            .read(adminStationsProvider.notifier)
                            .updateStation(updated);
                        if (context.mounted) {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Station Updated')),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
