import 'package:contacts/repositories/contact_dao.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../models/user_gender.dart';
import '../models/user_login_model.dart';
import '../models/user_type.dart';
import 'database.dart';

class UserDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      '$_id INTEGER PRIMARY KEY, '
      '$_name TEXT NOT NULL, '
      '$_email TEXT NOT NULL, '
      '$_password TEXT NOT NULL, '
      '$_dateOfBirth TEXT NOT NULL, '
      '$_gender INT NOT NULL, '
      '$_phone TEXT NOT NULL, '
      '$_type INT NOT NULL, '
      '$_profileImagePath TEXT, '
      '$_backgroundProfileImagePath TEXT )';

  static const String _tableName = 'users';
  static const String _id = 'id';
  static const String _name = 'name';
  static const String _email = 'email';
  static const String _password = 'password';
  static const String _dateOfBirth = 'dateOfBirth';
  static const String _gender = 'gender';
  static const String _phone = 'phone';
  static const String _type = 'type';
  static const String _profileImagePath = 'profileImagePath';
  static const String _backgroundProfileImagePath = 'backgroundProfileImagePath';

  Map<String, dynamic> _toMap(User user) {
    final Map<String, dynamic> userMap = {};
    userMap[_id] = user.id;
    userMap[_name] = user.name;
    userMap[_email] = user.email;
    userMap[_password] = user.password;
    userMap[_dateOfBirth] = user.dateOfBirth.toString();
    userMap[_gender] = user.gender?.index;
    userMap[_phone] = user.phone;
    userMap[_type] = user.type?.index;
    userMap[_profileImagePath] = user.profileImagePath;
    userMap[_backgroundProfileImagePath] = user.backgroundProfileImagePath;

    return userMap;
  }

  User _toUser(Map<String, dynamic> userMap) {
    return User(
      id: userMap[_id],
      name: userMap[_name],
      email: userMap[_email],
      password: userMap[_password],
      dateOfBirth: DateTime.tryParse(userMap[_dateOfBirth]),
      gender: UserGender.values[userMap[_gender]],
      phone: userMap[_phone],
      type: UserType.values[userMap[_type]],
      profileImagePath: userMap[_profileImagePath],
      backgroundProfileImagePath: userMap[_backgroundProfileImagePath],
    );
  }

  List<User> _toList(List<Map<String, dynamic>> result) {
    final List<User> users = [];

    for (Map<String, dynamic> row in result) {
      users.add(_toUser(row));
    }

    return users;
  }

  Future<int> save(User user) async {
    final Database db = await getDatabase();

    Map<String, dynamic> userMap = _toMap(user);

    if (user.id != null) {
      return await db.update(_tableName, userMap, where: "$_id = ${user.id}");
    }

    return await db.insert(_tableName, userMap);
  }

  Future<bool> delete(int id) async {
    final Database db = await getDatabase();

    return await db.delete(_tableName, where: "$_id = $id") > 0;
  }

  Future<List<User>> getAll() async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> result = await db.query(_tableName);
    List<User> users = _toList(result);

    return users;
  }

  Future<User?> getByEmail(String email) async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: "$_email = '$email'",
      limit: 1,
    );

    return result.isNotEmpty ? _toUser(result.first) : null;
  }

  Future<bool> userExists(int? id, String email) async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: "$_email = '$email' ${id != null ? 'AND $_id != $id' : ''}",
      limit: 1,
    );

    return result.isNotEmpty ? true : false;
  }

  Future<User?> signIn(UserLoginModel userLogin) async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where:
          "$_email = '${userLogin.email}' AND $_password = '${userLogin.password}'",
      limit: 1,
    );

    return result.isNotEmpty ? _toUser(result.first) : null;
  }
}
