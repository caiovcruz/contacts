import 'dart:convert';

import 'package:contacts/helpers/secure_storage_helper.dart';
import 'package:flutter/material.dart';

import '../helpers/navigator_helper.dart';
import '../widgets/app_bar.dart';
import '../widgets/contact_drawer.dart';
import '../helpers/contact_type_helper.dart';
import '../helpers/loading_helper.dart';
import '../models/contact.dart';
import '../models/contact_model.dart';
import '../models/user.dart';
import '../repositories/contact_dao.dart';
import 'contact_page.dart';

class ListContactPage extends StatefulWidget {
  const ListContactPage({Key? key}) : super(key: key);

  @override
  State<ListContactPage> createState() => _ListContactPageState();
}

class _ListContactPageState extends State<ListContactPage> {
  late ContactDao _contactDao;

  @override
  void initState() {
    super.initState();
    _contactDao = ContactDao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ContactDrawer(),
      appBar: getMenuAppBar(
        context,
        "Contacts",
        actions: getActionsAppBar(),
      ),
      body: FutureBuilder<List<Contact>>(
        future: loadContacts(),
        builder: (context, AsyncSnapshot<List<Contact>> contactsSnapshot) {
          if (contactsSnapshot.hasData) {
            return ListView.separated(
                itemBuilder: (context, index) {
                  final Contact contact = contactsSnapshot.data![index];
                  return ListTile(
                    onTap: () => editContact(context, contact),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child:
                          ContactTypeHelper.getIconByContactType(contact.type!),
                    ),
                    title: Text(contact.name!),
                    subtitle: Text(contact.phone!),
                    trailing: IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () => {},
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: contactsSnapshot.data!.length);
          }

          return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.mood_bad,
                    size: 50,
                  ),
                  Text("You don't have any contact yet...")
                ]),
          );
        },
      ),
    );
  }

  Future<List<Contact>> loadContacts() async {
    var userSignedIn =
        User.fromJson(jsonDecode((await SecureStorageHelper().read("USER"))!));

    return await _contactDao.getAll(userSignedIn.id);
  }

  addNewContact(BuildContext context) {
    NavigatorHelper().navigateToWidget(context, ContactPage());
  }

  editContact(BuildContext context, contact) {
    NavigatorHelper().navigateToWidget(
        context,
        ContactPage.edit(
          contact: BaseContactModel.fromContact(contact),
        ));
  }

  List<Widget>? getActionsAppBar() {
    return [
      IconButton(
        onPressed: () => addNewContact(context),
        icon: const Icon(Icons.add),
      ),
    ];
  }
}
