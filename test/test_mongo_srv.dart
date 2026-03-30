import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  var uriString = 'mongodb+srv://user:pass@cluster.mongodb.net/test';
  var uri = Uri.parse(uriString);
  print('Parsed scheme: ${uri.scheme}');

  try {
    print('Testing Db constructor with $uriString...');
    var db = Db(uriString);
    print('Db constructor succeeded');
  } catch (e) {
    print('Db constructor failed: $e');
  }
}
