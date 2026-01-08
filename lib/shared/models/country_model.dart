class Country {
  final String name;
  final String alpha2Code;
  final String alpha3Code;
  final List<String> callingCodes;

  Country({
    required this.name,
    required this.alpha2Code,
    required this.alpha3Code,
    required this.callingCodes,
  });

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      name: map['name'] ?? '',
      alpha2Code: map['alpha2Code'] ?? '',
      alpha3Code: map['alpha3Code'] ?? '',
      callingCodes: List<String>.from(map['callingCodes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'alpha2Code': alpha2Code,
      'alpha3Code': alpha3Code,
      'callingCodes': callingCodes,
    };
  }

  @override
  String toString() => name;
}
