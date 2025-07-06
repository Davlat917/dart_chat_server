import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main() async {
  final clients = <WebSocket>[];

  final handler = webSocketHandler((WebSocket socket) {
    print('🟢 Client connected.');
    clients.add(socket);

    socket.listen((message) {
      print('📨 Message: $message');
      for (var client in clients) {
        if (client != socket && client.readyState == WebSocket.open) {
          client.add(message);
        }
      }
    }, onDone: () {
      clients.remove(socket);
      print('🔴 Client disconnected.');
    });
  });

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  print('✅ Server running at ws://${server.address.host}:${server.port}/ws');
}
