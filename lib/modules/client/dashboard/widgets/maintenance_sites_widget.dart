import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/maintenance_site_model.dart';
import '../services/maintenance_service.dart';

class MaintenanceSitesWidget extends StatefulWidget {
  final int clientId;

  const MaintenanceSitesWidget({Key? key, required this.clientId})
    : super(key: key);

  @override
  State<MaintenanceSitesWidget> createState() => MaintenanceSitesWidgetState();
}

class MaintenanceSitesWidgetState extends State<MaintenanceSitesWidget> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  MaintenanceSitesResponse? _sitesData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSites();
  }

  Future<void> loadSites() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _maintenanceService.getClientMaintenanceSites(
        widget.clientId,
      );
      if (!mounted) return;
      setState(() {
        _sitesData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('ERROR loading maintenance sites: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.build_circle,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Sites en Maintenance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.black),
              ),
            )
          else if (_sitesData == null || _sitesData!.sites.isEmpty)
            // Empty state
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _sitesData?.message ??
                          "Vous n'avez pas de sites en maintenance",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Sites list
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sitesData!.message,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ..._sitesData!.sites
                    .map((site) => _buildSiteItem(site))
                    .toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSiteItem(MaintenanceSiteModel site) {
    final hasDate = site.lastMaintenanceDate != null;
    final DateTime? lastDate = hasDate
        ? DateTime.parse(site.lastMaintenanceDate!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDate
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language,
                  color: Colors.orange.shade700,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  site.url,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    "Dernière maintenance :",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasDate ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasDate
                      ? DateFormat('dd/MM/yyyy').format(lastDate!)
                      : "Non effectuée",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: hasDate
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
