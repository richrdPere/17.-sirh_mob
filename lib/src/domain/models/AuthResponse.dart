import 'dart:convert';

AuthResponse authResponseFromJson(String str) => AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
    final List<String> roles;
    final String message;
    final String token;
    final String username;

    AuthResponse({
        required this.roles,
        required this.message,
        required this.token,
        required this.username,
    });

    factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        roles: List<String>.from(json["roles"].map((x) => x)),
        message: json["message"],
        token: json["token"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "roles": List<dynamic>.from(roles.map((x) => x)),
        "message": message,
        "token": token,
        "username": username,
    };


    // final String token;
    // final UserModel user;

    // AuthResponse({
    //     required this.token,
    //     required this.user,
    // });

    // factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    //     token: json["token"],
    //     user: UserModel.fromJson(json["user"]),
    // );

    // Map<String, dynamic> toJson() => {
    //     "token": token,
    //     "user": user.toJson(),
    // };

  
}