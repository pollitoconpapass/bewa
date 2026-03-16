import './db_connector.dart';
import '../models/info_models.dart';
import '../utils/password_encryptation.dart';

class Authorizer {
  // Is Registered
  static Future<bool> isRegistered(String email) async {
    var db = await DBConnector.connect();
    User? user = await DBConnector.getUser(db, email);
    await DBConnector.close(db);
    return user != null;
  }

  // Is Authorized (can be used in Login)
  static Future<bool> isAuthorized(String email, String password) async {
    var db = await DBConnector.connect();
    User? user = await DBConnector.getUser(db, email);
    await DBConnector.close(db);
    return user != null && decryptPassword(user.password) == password;
  }
}
