class Lock {
  final String id;
  final double latitude;
  final double longitude;
  final bool locked;

  Lock({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.locked,
  });

  factory Lock.fromFirebase(String id, Map<String, dynamic> data) {
    return Lock(
      id: id,
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      locked: data['locked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'locked': locked,
    };
  }

  @override
  String toString() {
    return 'Lock(id: $id, latitude: $latitude, longitude: $longitude, locked: $locked)';
  }
}
