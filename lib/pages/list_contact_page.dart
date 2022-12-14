import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:contacts/helpers/message_helper.dart';
import 'package:contacts/helpers/secure_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late ValueNotifier<bool> _callLoading;
  late ValueNotifier<List<Contact>> _contacts;
  late ValueNotifier<bool> _contactsLoaded;
  late ValueNotifier<List<Contact>> _listedContacts;

  @override
  void initState() {
    super.initState();
    _contactDao = ContactDao();
    _searchController = TextEditingController();
    _addLoading = ValueNotifier<bool>(false);
    _callLoading = ValueNotifier<bool>(false);
    _contacts = ValueNotifier<List<Contact>>([]);
    _contactsLoaded = ValueNotifier<bool>(false);
    _listedContacts = ValueNotifier<List<Contact>>([]);

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
        child: ValueListenableBuilder(
          valueListenable: _contactsLoaded,
          builder: (context, contactsLoaded, _) {
            return Column(
              children: [
                _contactsLoaded.value
                    ? ValueListenableBuilder(
                        valueListenable: _contacts,
                        builder: (context, contacts, _) {
                          return _contacts.value.isNotEmpty
                              ? TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.search),
                                    hintText: "Search",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  onChanged: searchContact,
                                )
                              : Container();
                        },
                      )
                    : Container(),
                Expanded(
                  child: _contactsLoaded.value
                      ? ValueListenableBuilder(
                          valueListenable: _listedContacts,
                          builder: (context, contacts, _) {
                            if (_listedContacts.value.isNotEmpty) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: SizeConfig.safeBlockVertical * 2,
                                ),
                                child: RefreshIndicator(
                                  onRefresh: loadContacts,
                                  child: ListView.separated(
                                      itemBuilder: (context, index) {
                                        final Contact contact =
                                            _listedContacts.value[index];
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
                                              backgroundColor: Colors.grey[50],
                                              child: ContactTypeHelper
                                                  .getIconByContactType(
                                                      contact.type!),
                                            ),
                                            title: Text(contact.name!),
                                            subtitle: Text(contact.phone != null
                                                ? UtilBrasilFields
                                                    .obterTelefone(
                                                        contact.phone!)
                                                : contact.phone!),
                                            trailing: AnimatedBuilder(
                                                animation: _callLoading,
                                                builder: (context, _) {
                                                  return IconButton(
                                                    icon: _callLoading.value
                                                        ? LoadingHelper
                                                            .showLoading()
                                                        : Icon(
                                                            Icons.call,
                                                            color:
                                                                Colors.grey[50],
                                                          ),
                                                    onPressed: () {
                                                      if (!_callLoading.value) {
                                                        if (contact.phone !=
                                                            null) {
                                                          _callLoading.value =
                                                              !_callLoading
                                                                  .value;

                                                          Uri dialUrl = Uri(
                                                              scheme: "tel",
                                                              path:
                                                                  "55${contact.phone!}");

                                                          canLaunchUrl(dialUrl)
                                                              .then(
                                                                  (canLaunch) {
                                                            if (canLaunch) {
                                                              Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  () => launchUrl(
                                                                          dialUrl)
                                                                      .whenComplete(() => _callLoading
                                                                              .value =
                                                                          !_callLoading
                                                                              .value));
                                                            } else {
                                                              _callLoading
                                                                      .value =
                                                                  !_callLoading
                                                                      .value;

                                                              MessageHelper
                                                                  .showErrorMessage(
                                                                      context,
                                                                      "Could not launch dial, try again in few minutes!");
                                                            }
                                                          });
                                                        } else {
                                                          MessageHelper
                                                              .showErrorMessage(
                                                                  context,
                                                                  "Something went wrong, try again in few minutes!");
                                                        }
                                                      }
                                                    },
                                                  );
                                                }),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                            color: Colors.transparent,
                                          ),
                                      itemCount: _listedContacts.value.length),
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
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              SizeConfig.safeBlockVertical * 2),
                                      child: const Text(
                                          "You don't have any contact yet..."),
                                    )
                                  ]),
                            );
                          },
                        )
                      : LoadingHelper.showCenteredLoading(),
                ),
              ],
            );
          },
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
    _addLoading.value = !_addLoading.value;

    NavigatorHelper().showPageModal(context, ContactPage());

    Future.delayed(const Duration(milliseconds: 500),
        () => _addLoading.value = !_addLoading.value);
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
      AnimatedBuilder(
          animation: _addLoading,
          builder: (context, _) {
            return IconButton(
              onPressed: () => addNewContact(context),
              icon: _addLoading.value
                  ? LoadingHelper.showButtonLoading()
                  : const Icon(Icons.add),
            );
          }),
    ];
  }

  void searchContact(String value) {
    if (value.isNotEmpty) {
      _listedContacts.value = _contacts.value.where(
        (contact) {
          final contactName = contact.name?.toLowerCase();
          final contactPhone = contact.phone?.toLowerCase();
          final input = value.toLowerCase();

          return (contactName?.contains(input) ?? false) ||
              (contactPhone?.contains(input) ?? false);
        },
      ).toList();
    } else {
      _listedContacts.value = _contacts.value;
    }
  }
}
