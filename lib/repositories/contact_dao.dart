import 'package:contacts/models/contact_type.dart';
import 'package:sqflite/sqflite.dart';

import '../models/contact.dart';
import 'database.dart';

class ContactDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      '$_id INTEGER PRIMARY KEY, '
      '$_userId INTEGER, '
      '$_name TEXT, '
      '$_email TEXT, '
      '$_cpf INTEGER, '
      '$_phone TEXT, '
      '$_type INT, '
      'FOREIGN KEY($_userId) REFERENCES $_foreignUserTableName($_id) )';

  static const String _tableName = 'contacts';
  static const String _foreignUserTableName = 'users';
  static const String _id = 'id';
  static const String _userId = 'user_id';
  static const String _name = 'name';
  static const String _email = 'email';
  static const String _cpf = 'cpf';
  static const String _phone = 'phone';
  static const String _type = 'type';

  Map<String, dynamic> _toMap(Contact contact) {
    final Map<String, dynamic> contactMap = {};
    contactMap[_id] = contact.id;
    contactMap[_userId] = contact.userId;
    contactMap[_name] = contact.name;
    contactMap[_email] = contact.email;
    contactMap[_cpf] = contact.cpf;
    contactMap[_phone] = contact.phone;
    contactMap[_type] = contact.type?.index;

    return contactMap;
  }

  Contact _toContact(Map<String, dynamic> contactMap) {
    return Contact(
      id: contactMap[_id],
      userId: contactMap[_userId],
      name: contactMap[_name],
      email: contactMap[_email],
      cpf: contactMap[_cpf],
      phone: contactMap[_phone],
      type: ContactType.values[contactMap[_type]],
    );
  }

  List<Contact> _toList(List<Map<String, dynamic>> result) {
    final List<Contact> contacts = [];

    for (Map<String, dynamic> row in result) {
      contacts.add(_toContact(row));
    }

    return contacts;
  }

  Future<int> save(Contact contact) async {
    final Database db = await getDatabase();

    Map<String, dynamic> contactMap = _toMap(contact);

    if (contact.id != null) {
      return await db.update(_tableName, contactMap,
          where: "$_id = ${contact.id}");
    }

    return await db.insert(_tableName, contactMap);
  }

  Future<bool> delete(int userId, int id) async {
    final Database db = await getDatabase();

    return await db.delete(_tableName,
            where: "$_userId = $userId AND $_id = $id") >
        0;
  }

  Future<List<Contact>> getAll(int? userId) async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: "$_userId = $userId",
    );

    List<Contact> contacts = _toList(result);

    return contacts;
  }

  Future<bool> contactExists(int? userId, int? id, String phone) async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: "$_userId = $userId AND $_id != $id AND $_phone = '$phone'",
      limit: 1,
    );

    return result.isNotEmpty ? true : false;
  }
}
