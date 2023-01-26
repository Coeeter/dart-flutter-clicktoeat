import 'package:clicktoeat/domain/branch/branch.dart';

abstract class RemoteBranchDao {
  Future<List<Branch>> getAllBranches();
  Future<String> createBranch({
    required String token,
    required String restaurantId,
    required String address,
    required double latitude,
    required double longitude,
  });
  Future<void> deleteBranch({
    required String token,
    required String branchId,
    required String restaurantId,
  });
}