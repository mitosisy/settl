import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.devnet.solana.com', headers: {'Content-Type': 'application/json'}));
  try {
    final response = await dio.post('', data: {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'getTransaction',
      'params': ['39hWCWc8pZf2GS5BYfjMUwLC6FE7S3bmBrM1QANYwiRc53uHH3JYWdxq81JxzeHyHJn9wzbHn8PwUtcN3yWmNEzb', {'encoding': 'jsonParsed', 'maxSupportedTransactionVersion': 0}]
    });
    print(response.data);
  } catch (e) {
    print(e);
  } finally {
    dio.close();
  }
}
