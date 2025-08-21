class User {
  final int? userId;
  final String? nickname;
  final String? email;
  final String? profileUrl;
  final String? providerType;
  final String? accessToken;
  final bool? isNewUser;
  final String? fcmToken;

  User({
    this.userId,
    this.nickname,
    this.email,
    this.profileUrl,
    this.providerType,
    this.accessToken,
    this.isNewUser,
    this.fcmToken,
  });

  User.fromMap(Map<String, dynamic> data)
    : userId = data['userId'],
      nickname = data['nickname'],
      email = data['email'],
      profileUrl = data['profileUrl'],
      providerType = data['providerType'],
      accessToken = data['token'],
      isNewUser = data['isNewUser'],
      fcmToken = data['fcmToken'];
}
