import '../../../core/network/api_client.dart';
import '../models/branch_racket_service.dart';

class RacketServiceApi {
  RacketServiceApi({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Retained so this data source can switch back to the backend after UI testing.
  // ignore: unused_field
  final ApiClient _apiClient;

  Future<List<BranchRacketService>> getAvailableServices(
    String branchId,
  ) async {
    return const [
      BranchRacketService(
        id: 's1',
        branchId: 'br1',
        serviceId: 'srv1',
        service: RacketServiceInfo(
          id: 'srv1',
          name: 'Đan vợt cầu lông',
          description: 'Đan vợt chuyên nghiệp',
          imageUrl: '/uploads/images/products/service-cang-day-vot.jpg',
        ),
        referencePrice: 50000,
        estimatedDuration: '30 phút',
      ),
      BranchRacketService(
        id: 's2',
        branchId: 'br1',
        serviceId: 'srv2',
        service: RacketServiceInfo(
          id: 'srv2',
          name: 'Quấn cán vợt',
          description: 'Quấn cán chống mồ hôi',
          imageUrl: '/uploads/images/products/service-thay-quan-can.jpg',
        ),
        referencePrice: 20000,
        estimatedDuration: '10 phút',
      ),
      BranchRacketService(
        id: 's3',
        branchId: 'br1',
        serviceId: 'srv3',
        service: RacketServiceInfo(
          id: 'srv3',
          name: 'Kiểm tra và sửa khung vợt',
          description: 'Kiểm tra khung, gen và tư vấn phương án sửa phù hợp.',
          imageUrl: '/uploads/images/products/service-sua-khung-vot.jpg',
        ),
        referencePrice: 100000,
        estimatedDuration: '1 - 2 ngày',
      ),
    ];
  }
}
