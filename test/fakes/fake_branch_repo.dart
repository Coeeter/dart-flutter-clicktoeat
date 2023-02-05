import 'package:clicktoeat/domain/branch/branch.dart';
import 'package:clicktoeat/domain/branch/branch_repo.dart';
import 'package:clicktoeat/domain/common/image.dart';
import 'package:clicktoeat/domain/restaurant/restaurant.dart';

class FakeBranchRepo implements BranchRepo {
  List<Branch> _branches = [];

  FakeBranchRepo() {
    _branches = List.generate(
      10,
      (index) => Branch(
        id: index.toString(),
        address: 'Address $index',
        latitude: 0.0,
        longitude: 0.0,
        restaurant: _createRestaurant(index.toString()),
      ),
    );
  }

  Restaurant _createRestaurant(String restaurantId) {
    return Restaurant(
      id: restaurantId,
      name: "name $restaurantId",
      description: "description $restaurantId",
      branches: [],
      image: Image(
        id: int.parse(restaurantId),
        key: "key",
        url: 'https://picsum.photos/200/200',
      ),
    );
  }

  @override
  Future<String> createBranch({
    required String token,
    required String restaurantId,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    var branch = Branch(
      id: _branches.length.toString(),
      address: address,
      latitude: latitude,
      longitude: longitude,
      restaurant: _createRestaurant(restaurantId),
    );
    _branches.add(branch);
    return branch.id;
  }

  @override
  Future<void> deleteBranch({
    required String token,
    required String branchId,
    required String restaurantId,
  }) async {
    _branches.removeWhere((element) => element.id == branchId);
  }

  @override
  Future<List<Branch>> getAllBranches() async {
    return _branches;
  }
}
