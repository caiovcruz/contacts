import 'dart:convert';

import 'package:contacts/helpers/secure_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/navigator_helper.dart';
import '../helpers/size_config.dart';
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
  late TextEditingController _searchController;
  late ValueNotifier<bool> _addLoading;
  late ValueNotifier<List<Contact>?> _contacts;
  late ValueNotifier<bool> _contactsLoaded;
  late ValueNotifier<List<Contact>?> _listedContacts;

  @override
  void initState() {
    super.initState();
    _contactDao = ContactDao();
    _searchController = TextEditingController();
    _addLoading = ValueNotifier<bool>(false);
    _contacts = ValueNotifier<List<Contact>?>(null);
    _contactsLoaded = ValueNotifier<bool>(false);
    _listedContacts = ValueNotifier<List<Contact>?>(null);

    loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      drawer: const ContactDrawer(),
      appBar: getMenuAppBar(
        context,
        "Contacts",
        actions: getActionsAppBar(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.safeBlockVertical * 3,
          horizontal: SizeConfig.safeBlockVertical * 3,
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              onChanged: searchContact,
            ),
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: _contactsLoaded,
                  builder: (context, contactsLoaded, _) {
                    return _contactsLoaded.value
                        ? ValueListenableBuilder(
                            valueListenable: _listedContacts,
                            builder: (context, contacts, _) {
                              if (_listedContacts.value != null) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: SizeConfig.safeBlockVertical * 2,
                                  ),
                                  child: RefreshIndicator(
                                    onRefresh: loadContacts,
                                    child: ListView.separated(
                                        itemBuilder: (context, index) {
                                          final Contact contact =
                                              _listedContacts.value![index];
                                          return DecoratedBox(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                gradient: const LinearGradient(
                                                    colors: [
                                                      Colors.deepPurple,
                                                      Colors.purple
                                                    ])),
                                            child: ListTile(
                                              textColor: Colors.grey[50],
                                              onTap: () =>
                                                  editContact(context, contact),
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[50],
                                                child: ContactTypeHelper
                                                    .getIconByContactType(
                                                        contact.type!),
                                              ),
                                              title: Text(contact.name!),
                                              subtitle: Text(contact.phone!),
                                              trailing: IconButton(
                                                icon: Icon(
                                                  Icons.call,
                                                  color: Colors.grey[50],
                                                ),
                                                onPressed: () => {},
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const Divider(
                                              color: Colors.transparent,
                                            ),
                                        itemCount:
                                            _listedContacts.value!.length),
                                  ),
                                );
                              }

                              return Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.mood_bad,
                                        size: SizeConfig.safeBlockHorizontal * 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 2),
                                        child: const Text("You don't have any contact yet..."),
                                      )
                                    ]),
                              );
                            },
                          )
                        : LoadingHelper.showLoading();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadContacts() async {
    var userSignedIn =
        User.fromJson(jsonDecode((await SecureStorageHelper().read("USER"))!));

    _contacts.value = await _contactDao.getAll(userSignedIn.id);
    _contactsLoaded.value = true;
    _listedContacts.value = _contacts.value;
  }

  void addNewContact(BuildContext context) {
    NavigatorHelper().navigateToWidget(context, ContactPage());
  }

  void editContact(BuildContext context, contact) {
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
        icon: _addLoading.value
            ? LoadingHelper.showButtonLoading()
            : const Icon(Icons.add),
      ),
    ];
  }

  void searchContact(String value) {
    if (value.isNotEmpty) {
      _listedContacts.value = _contacts.value?.where((contact) {
        final contactName = contact.name?.toLowerCase();
        final contactPhone = contact.phone?.toLowerCase();
        final input = value.toLowerCase();

        return (contactName?.contains(input) ?? false) ||
            (contactPhone?.contains(input) ?? false);
      }).toList();
    } else {
      _listedContacts.value = _contacts.value;
    }
  }
}
