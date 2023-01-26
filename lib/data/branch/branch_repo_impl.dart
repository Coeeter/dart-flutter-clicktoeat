import 'package:clicktoeat/data/branch/remote/remote_branch_dao.dart';
import 'package:clicktoeat/domain/branch/branch.dart';
import 'package:clicktoeat/domain/branch/branch_repo.dart';

class BranchRepoImpl implements BranchRepo {
  final RemoteBranchDao _dao;

  BranchRepoImpl({required RemoteBranchDao remoteBranchDao})
      : _dao = remoteBranchDao;

  @override
  Future<String> createBranch({
    required String token,
    required String restaurantId,
    required String address,
    required double latitude,
    required double longitude,
  }) {
    return _dao.createBranch(
      token: token,
      restaurantId: restaurantId,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<void> deleteBranch({
    required String token,
    required String branchId,
    required String restaurantId,
  }) {
    return _dao.deleteBranch(
      token: token,
      branchId: branchId,
      restaurantId: restaurantId,
    );
  }

  @override
  Future<List<Branch>> getAllBranches() {
    return _dao.getAllBranches();
  }
}
