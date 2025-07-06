import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main() async {
  final clients = <WebSocket>[];
  final messageHistory = <String>[]; // Tarixni saqlash

  final handler = webSocketHandler((WebSocket socket) {
    print('🟢 Client connected.');
    clients.add(socket);

    // Eski xabarlarni yuborish
    for (var msg in messageHistory) {
      socket.add('[OLD] $msg');
    }

    socket.listen((message) {
      print('📨 Message: $message');
      messageHistory.add(message);

      for (var client in clients) {
        if (client.readyState == WebSocket.open) {
          client.add(message);
        }
      }
    }, onDone: () {
      clients.remove(socket);
      print('🔴 Client disconnected.');
    });
  });

  final pipeline = Pipeline().addMiddleware(logRequests()).addHandler(handler);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server =
      await shelf_io.serve(pipeline, InternetAddress.anyIPv4, port);

  print('✅ Server running at ws://${server.address.host}:${server.port}/ws');
}
