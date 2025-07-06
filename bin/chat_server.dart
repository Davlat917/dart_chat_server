import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

final connectedClients = <WebSocket>[];

void main() async {
  final handler = Cascade().add(webSocketHandler((WebSocket socket) {
        connectedClients.add(socket);
        print('🟢 Client connected. Total: ${connectedClients.length}');

        socket.listen(
          (message) {
            print('📨 Message: $message');
            for (var client in connectedClients) {
              if (client.readyState == WebSocket.open) {
                client.add(message);
              }
            }
          },
          onDone: () {
            connectedClients.remove(socket);
            print('🔴 Client disconnected. Total: ${connectedClients.length}');
          },
        );
      }))
      .add((Request request) => Response.ok('✅ Chat server is running'))
      .handler;

  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('🚀 Serving at ws://${server.address.host}:${server.port}');
}
