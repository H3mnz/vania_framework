import 'package:vania/src/container.dart';
import 'package:vania/src/server/base_http_server.dart';
import 'package:vania/vania.dart';

class Application extends Container{
  static Application? _singleton;

  factory Application() {
    _singleton ??= Application._internal();
    return _singleton!;
  }

  Application._internal();

  BaseHttpServer get server => BaseHttpServer();


  Future<void> initialize({required Map<String,dynamic> config }) async{

    if(config['key'] == '' || config['key'] == null){
      throw Exception('Key not found');
    }
    
    Config().setApplicationConfig = config;


    List<ServiceProvider> provider = config['providers'];

    for(ServiceProvider provider in provider){
      provider.register();
    }

      DatabaseDriver? db = Config().get('database')?.driver ;
      if(db !=null){
          await db.init();
      }
    
    

    server.startServer(host: config['host'], port: config['port']);
  }


}