import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // 🔥 Muhim!

void main() async {
  final clients = <WebSocketChannel>[];

  final handler = webSocketHandler((WebSocketChannel channel) {
    print('🟢 Client connected.');
    clients.add(channel);

    channel.stream.listen((message) {
      print('📨 Message: $message');
      for (var client in clients) {
        if (client != channel) {
          client.sink.add(message); // 💡 channel.sink bilan yuboriladi
        }
      }
    }, onDone: () {
      clients.remove(channel);
      print('🔴 Client disconnected.');
    });
  });

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server =
      await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Server running at ws://${server.address.host}:${server.port}/');
}
