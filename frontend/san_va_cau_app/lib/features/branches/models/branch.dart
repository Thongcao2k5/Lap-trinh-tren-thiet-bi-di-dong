import '../../../core/constants/api_config.dart';

class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.status,
    this.phone,
    this.description,
    this.imageUrl,
    this.mapUrl,
    this.isFeatured = false,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String address;
  final String? phone;
  final String openingTime;
  final String closingTime;
  final String status;
  final String? description;
  final String? imageUrl;
  final String? mapUrl;
  final bool isFeatured;
  final int sortOrder;

  String get resolvedMapUrl {
    if (mapUrl != null && mapUrl!.isNotEmpty) {
      return mapUrl!;
    }
    final lowerName = name.toLowerCase();
    final lowerAddress = address.toLowerCase();

    if (lowerName.contains('quận 1') || lowerAddress.contains('minh khai')) {
      return 'https://www.google.com/maps/search/?api=1&query=S%C3%A2n+c%E1%BA%A7u+l%C3%B4ng+Cung+V%C4%83n+h%C3%B3a+Lao+%C4%91%E1%BB%99ng%2C+55B+Nguy%E1%BB%85n+Th%E1%BB%8B+Minh+Khai%2C+Ph%C6%B0%E1%BB%9Dng+B%E1%BA%BFn+Th%C3%A0nh%2C+Qu%E1%BA%ADn+1%2C+TP.+H%E1%BB%93+Ch%C3%AD+Minh';
    }
    if (lowerName.contains('thủ đức') || lowerAddress.contains('trường thọ') || lowerAddress.contains('đường số 2')) {
      return 'https://maps.app.goo.gl/kqmA3zLPSBjaM7496';
    }
    if (lowerName.contains('bình thạnh') || lowerAddress.contains('bình quới')) {
      return 'https://maps.app.goo.gl/MqZCMWV2ptLosZ7YA';
    }
    final query = Uri.encodeComponent(address.isNotEmpty ? '$name, $address' : name);
    return 'https://www.google.com/maps/search/?api=1&query=$query';
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString(),
      openingTime: json['openingTime']?.toString() ?? '',
      closingTime: json['closingTime']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl'] == null
          ? null
          : json['imageUrl'].toString().startsWith('assets/')
          ? json['imageUrl'].toString()
          : ApiConfig.resolveMediaUrl(json['imageUrl'].toString()),
      mapUrl: json['mapUrl']?.toString(),
      isFeatured: json['isFeatured'] == true,
      sortOrder: json['sortOrder'] is int ? json['sortOrder'] as int : 0,
    );
  }
}
