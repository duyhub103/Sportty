import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  static final SocketClient _instance = SocketClient._internal();
  factory SocketClient() => _instance;
  SocketClient._internal();

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  void initSocket({VoidCallback? onConnected}) {
    // Đã connect rồi thì gọi callback luôn và thoát
    if (_socket != null && _socket!.connected) {
      onConnected?.call();
      return;
    }

    _socket = IO.io('http://192.168.1.2:3000', IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Đã kết nối Socket.IO thành công (ID: ${_socket!.id})');
      onConnected?.call(); // 👈 gọi callback khi connect xong
    });

    _socket!.onDisconnect((_) {
      print('Đã ngắt kết nối Socket.IO');
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }
}