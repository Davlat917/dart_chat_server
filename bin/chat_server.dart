import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main() async {
  final clients = <WebSocket>[];
  final messages = <String>[]; // 🧠 Bu yerda barcha xabarlar saqlanadi

  final handler = Cascade()
      .add((Request request) {
        if (request.url.path == 'ws') {
          return webSocketHandler((WebSocket socket) {
            print('🟢 Client connected.');
            clients.add(socket);

            // 🧾 Ulanishda eski xabarlarni yuborish
            if (messages.isNotEmpty) {
              socket.add(messages); // ⚠️ shelf_web_socket 2.0.0 versiyada List yuboriladi
            }

            socket.listen((message) {
              print('📨 Message: $message');

              messages.add(message); // 🧠 Tarixga qo‘shamiz

              // 🔁 Boshqalarga yuboramiz
              for (var client in clients) {
                if (client != socket && client.readyState == WebSocket.open) {
                  client.add(message);
                }
              }
            }, onDone: () {
              clients.remove(socket);
              print('🔴 Client disconnected.');
            });
          })(request);
        }

        return Response.notFound('Not Found');
      })
      .handler;

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  print('✅ Server running at ws://${server.address.host}:${server.port}/ws');
}
