
class UserTokens{
  String jwtToken;
  DateTime? loginTimeStamp;
  String? refreshToken;
  DateTime? refreshTokenExpiry;

  UserTokens(
      this.jwtToken,
      this.loginTimeStamp,
      this.refreshToken,
      this.refreshTokenExpiry,
      );
}