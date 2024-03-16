import 'package:vania/src/container.dart';
import 'package:vania/src/exception/invalid_argument_exception.dart';
import 'package:vania/src/server/base_http_server.dart';
import 'package:vania/vania.dart';

class Application extends Container {
  static Application? _singleton;

  factory Application() {
    _singleton ??= Application._internal();
    return _singleton!;
  }

  Application._internal();

  BaseHttpServer get server => BaseHttpServer();

  Future<void> initialize({required Map<String, dynamic> config}) async {
    if (config['key'] == '' || config['key'] == null) {
      throw Exception('Key not found');
    }

    Config().setApplicationConfig = config;

    List<ServiceProvider> provider = config['providers'];

    for (ServiceProvider provider in provider) {
      provider.register();
      provider.boot();
    }

    try {
      DatabaseConfig? db = Config().get('database');
      if (db != null) {
        await db.driver?.init(Config().get('database'));
      }
    } on InvalidArgumentException catch (_) {
      print('Error establishing a database connection');
      rethrow;
    }

    if (config['isolate']) {
      server.spawnIsolates(config['isolateCount']);
    } else {
      server.startServer(host: config['host'], port: config['port']);
    }
  }

  Future<void> close() async {
    if (Config().get("isolate")) {
      server.killAllIsolates();
    } else {
      server.httpServer?.close();
    }
  }
}
