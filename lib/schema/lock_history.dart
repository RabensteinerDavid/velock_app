import 'package:velock_app/schema/lock.dart';

class LockHistory extends Lock {
  final String timestamp;

  LockHistory({
    required super.id,
    required super.latitude,
    required super.longitude,
    required super.locked,
    required this.timestamp,
  });

  factory LockHistory.fromFirebase(String id, Map<String, dynamic> data) {
    return LockHistory(
      id: id,
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      locked: data['locked'] ?? false,
      timestamp: data['timestamp']?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['timestamp'] = timestamp;
    return json;
  }

  @override
  String toString() {
    return 'LockHistory(id: $id, latitude: $latitude, longitude: $longitude, locked: $locked, timestamp: $timestamp)';
  }
}
