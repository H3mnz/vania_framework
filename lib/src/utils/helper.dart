import 'dart:io';
import 'package:vania/src/localization_handler/localization.dart';
import 'package:vania/vania.dart';

String storagePath(String file) => 'storage/$file';

String publicPath(String file) => 'public/$file';

String url(String path) => '${env<String>('APP_URL')}/$path';

String assets(String src) => url(src);

bool can(String ability) => Gate().allows(ability);

bool cannot(String ability) => Gate().denies(ability);

T env<T>(String key, [dynamic defaultValue]) => Env.get<T>(key, defaultValue);

String trans(
  String key, [
  Map<String, dynamic>? args,
]) =>
    Localization().trans(
      key,
      args,
    );

abort(int code, String message) {
  throw HttpResponseException(message: message, code: code);
}

// Databse Helper
Connection? get connection => DatabaseClient().database?.connection;

// DB Transaction
void dbTransaction(
  Future<void> Function(Connection connection) callback, [
  int? timeoutInSeconds,
]) {
  connection?.transaction(
    (con) async {
      callback(con);
    },
    timeoutInSeconds,
  ).onError((e, _) {
    throw HttpResponseException(
      message: "DbTransaction error: ${e.toString()}",
      code: HttpStatus.internalServerError,
    );
  });
}
