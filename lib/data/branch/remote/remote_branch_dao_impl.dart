import 'dart:convert';

import 'package:clicktoeat/data/branch/remote/remote_branch_dao.dart';
import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/data/utils/network_utils.dart';
import 'package:clicktoeat/domain/branch/branch.dart';
import 'package:http/http.dart';

class RemoteBranchDaoImpl extends NetworkUtils implements RemoteBranchDao {
  RemoteBranchDaoImpl() : super(path: "/api/branches");

  @override
  Future<String> createBranch({
    required String token,
    required String restaurantId,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    var response = await post(
      createUrl(endpoint: "/$restaurantId"),
      headers: createAuthorizationHeader(token),
      body: {
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      },
    );
    if (response.statusCode == 400) {
      throw FieldException.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    Map<String, dynamic> body = jsonDecode(response.body);
    return body["insertId"];
  }

  @override
  Future<void> deleteBranch({
    required String token,
    required String branchId,
    required String restaurantId,
  }) async {
    var response = await delete(
      createUrl(endpoint: "/$branchId"),
      headers: createAuthorizationHeader(token),
      body: {
        "restaurantId": restaurantId,
      },
    );
    if (response.statusCode == 200) return;
    if (response.statusCode == 400) {
      throw FieldException.fromJson(jsonDecode(response.body));
    }
    throw DefaultException.fromJson(jsonDecode(response.body));
  }

  @override
  Future<List<Branch>> getAllBranches() async {
    var response = await get(createUrl());
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    List<Map<String, dynamic>> body = jsonDecode(response.body);
    return body.map((e) => Branch.fromJson(e)).toList();
  }
}
