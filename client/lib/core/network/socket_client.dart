import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  // Biến instance Singleton
  static final SocketClient _instance = SocketClient._internal();
  
  // Trả về cùng một instance mỗi khi được gọi
  factory SocketClient() {
    return _instance;
  }

  SocketClient._internal();

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  // Hàm khởi tạo kết nối (gọi khi Đăng nhập thành công)
  void initSocket() {
    if (_socket != null && _socket!.connected) return; // Đã kết nối thì thôi

    // địa chỉ ip wifi của máy tính
    _socket = IO.io('http://10.0.2.2:3000', IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Đã kết nối Socket.IO thành công (ID: ${_socket!.id})');
    });

    _socket!.onDisconnect((_) {
      print('Đã ngắt kết nối Socket.IO');
    });
  }

  // Hàm ngắt kết nối (Thường gọi khi Đăng xuất)
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }
}