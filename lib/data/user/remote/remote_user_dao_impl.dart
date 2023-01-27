import 'dart:convert';
import 'dart:io';

import 'package:clicktoeat/data/exceptions/default_exception.dart';
import 'package:clicktoeat/data/exceptions/field_exception.dart';
import 'package:clicktoeat/data/exceptions/unauthenticated_exception.dart';
import 'package:clicktoeat/data/user/remote/remote_user_dao.dart';
import 'package:clicktoeat/domain/user/user.dart';
import 'package:http/http.dart';
import 'package:clicktoeat/data/utils/network_utils.dart';

class RemoteUserDaoImpl extends NetworkUtils implements RemoteUserDao {
  RemoteUserDaoImpl() : super(path: "/api/users");

  @override
  Future<void> deleteAccount({
    required String token,
    required String password,
  }) async {
    var response = await delete(
      createUrl(),
      headers: createAuthorizationHeader(token),
      body: {
        "password": password,
      },
    );
    if (response.statusCode == 200) return;
    var body = jsonDecode(response.body);
    if (response.statusCode == 400) {
      throw FieldException.fromJson(body);
    }
    throw DefaultException.fromJson(body);
  }

  @override
  Future<List<User>> getAllUsers() async {
    var response = await get(createUrl());
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    var body = jsonDecode(response.body) as List;
    return body.map((e) => User.fromJson(e)).toList();
  }

  @override
  Future<User> getUserById({required String id}) async {
    var response = await get(createUrl(endpoint: "/$id"));
    var body = jsonDecode(response.body);
    if (body == null) {
      throw DefaultException(error: "No user with id $id found");
    }
    return User.fromJson(body);
  }

  @override
  Future<User> getUserByToken({required String token}) async {
    var response = await get(
      createUrl(endpoint: "/validate-token"),
      headers: createAuthorizationHeader(token),
    );
    if (response.statusCode != 200) {
      throw UnauthenticatedException();
    }
    var body = jsonDecode(response.body);
    return User.fromJson(body);
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    var response = await post(
      createUrl(endpoint: "/login"),
      body: {
        "email": email,
        "password": password,
      },
    );
    if (response.statusCode == 400) {
      throw FieldException.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    var body = jsonDecode(response.body) as Map;
    var token = body["token"];
    if (token == null) {
      throw DefaultException(error: "Unknown error has occurred");
    }
    return token;
  }

  @override
  Future<String> register({
    required String username,
    required String email,
    required String password,
    File? image,
  }) async {
    var request = MultipartRequest(
      "POST",
      createUrl(endpoint: "/create-account"),
    );
    request.fields
      ..["username"] = username
      ..["email"] = email
      ..["password"] = password;
    if (image != null) {
      request.files.add(
        await MultipartFile.fromPath("image", image.path),
      );
    }
    var response = await Response.fromStream(await request.send());
    if (response.statusCode == 400) {
      throw FieldException.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    var body = jsonDecode(response.body) as Map;
    var token = body["token"];
    if (token == null) {
      throw DefaultException(error: "Unknown error has occurred");
    }
    return token;
  }

  @override
  Future<String> sendPasswordResetLinkToEmail({required String email}) async {
    var response = await post(
      createUrl(endpoint: "/forget-password"),
      body: {"email": email},
    );
    if (response.statusCode == 400) {
      throw FieldException.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    var body = jsonDecode(response.body) as Map;
    var message = body["message"];
    if (message == null) {
      throw DefaultException(error: "Unknown error has occurred");
    }
    return message;
  }

  @override
  Future<String> updateAccount({
    required String token,
    String? username,
    String? email,
    String? password,
    File? image,
    bool? deleteImage,
  }) async {
    var request = MultipartRequest("PUT", createUrl())
      ..headers["authorization"] = "Bearer $token";
    int length = 0;
    if (username != null) {
      request.fields["username"] = username;
      length += 1;
    }
    if (email != null) {
      request.fields["email"] = email;
      length += 1;
    }
    if (password != null) {
      request.fields["password"] = password;
      length += 1;
    }
    if (deleteImage != null) {
      request.fields["deleteImage"] = deleteImage.toString();
      length += 1;
    }
    if (image != null) {
      request.files.add(await MultipartFile.fromPath("image", image.path));
      length += 1;
    }
    if (length == 0) {
      throw DefaultException(error: "Must have at least one field to update!");
    }
    var response = await Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw DefaultException.fromJson(jsonDecode(response.body));
    }
    var body = jsonDecode(response.body) as Map;
    var updatedToken = body["token"];
    if (updatedToken == null) {
      throw DefaultException(error: "Unknown error has occurred");
    }
    return updatedToken;
  }
}
