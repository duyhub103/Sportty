// máy ảo chạy Android: ip 10.0.2.2
// chạy máy thật (web) thì dùng IP LAN mấy Host (ví dụ 192.168.x.x) hoặc localhost
// chạy điện thoại thật thì điện thoại và máy tính phải cùng mạng LAN (ví dụ 192.168.1.x)
class ApiConstants{
  //static const String baseUrl = 'http://10.0.2.2:3000/api'; // máy ảo Android
  //static const String baseUrl = 'http://localhost:3000/api'; // chạy máy thật trên nền web
  static const String baseUrl = 'http://192.168.1.2:3000/api'; // máy thật dùng IP LAN

  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String userProfileEndpoint = '$baseUrl/user/profile';

}