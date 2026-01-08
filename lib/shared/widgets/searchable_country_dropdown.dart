import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../utils/countries_data.dart';
import '../utils/ui_helpers.dart';

class SearchableCountryDropdown extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<Country> onSelected;
  final bool enabled;

  const SearchableCountryDropdown({
    super.key,
    this.initialValue,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  State<SearchableCountryDropdown> createState() =>
      _SearchableCountryDropdownState();
}

class _SearchableCountryDropdownState extends State<SearchableCountryDropdown> {
  late TextEditingController _displayController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(SearchableCountryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _displayController.text = widget.initialValue ?? '';
        }
      });
    }
  }

  void _showCountryPicker() {
    showAppModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerSheet(
        onSelected: (country) {
          setState(() {
            _displayController.text = country.name;
          });
          widget.onSelected(country);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: widget.enabled ? _showCountryPicker : null,
        borderRadius: BorderRadius.circular(12),
        child: IgnorePointer(
          child: TextFormField(
            controller: _displayController,
            decoration: InputDecoration(
              labelText: "Pays",
              filled: !widget.enabled,
              fillColor: widget.enabled
                  ? Colors.transparent
                  : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final ValueChanged<Country> onSelected;

  const _CountryPickerSheet({required this.onSelected});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _searchQuery = "";
  final List<Country> _allCountries = allCountries;

  List<Country> get _filteredCountries {
    if (_searchQuery.isEmpty) return _allCountries;
    return _allCountries.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.alpha2Code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Rechercher un pays...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return ListTile(
                  title: Text(country.name),
                  trailing: Text(
                    country.alpha2Code,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    widget.onSelected(country);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
