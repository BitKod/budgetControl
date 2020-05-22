import 'package:budgetControl/core/init/locale_keys.g.dart';
import 'package:budgetControl/core/init/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/view/base/base_state.dart';
import '../../core/view/widget/card/text_input_card.dart';
import '../../core/view/widget/loading/loading.dart';
import '../models/bank.dart';
import '../models/credit_card.dart';
import '../models/fixed_expense.dart';
import '../models/invoice.dart';
import '../services/database_bank.dart';
import '../services/database_credit_card.dart';
import '../services/database_fixed_expense.dart';
import '../services/database_invoice.dart';

class DataInput extends StatefulWidget {
  const DataInput({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DataInputState();
}

class _DataInputState extends BaseState<DataInput> {
  final GlobalKey<ScaffoldState> _scaffoldKeyDataInput =
      new GlobalKey<ScaffoldState>();

  final _bankFormKey = GlobalKey<FormState>();
  final _bankIdController = TextEditingController();
  final _bankNameBankController = TextEditingController();
  final _accountTypeController = TextEditingController();
  final _ownerBankController = TextEditingController();

  final _creditCardFormKey = GlobalKey<FormState>();
  final _creditCardIdController = TextEditingController();
  final _bankNameCreditCardController = TextEditingController();
  final _cardTypeController = TextEditingController();
  final _ownerCreditCardController = TextEditingController();

  final _invoiceFormKey = GlobalKey<FormState>();
  final _invoiceIdController = TextEditingController();
  final _incoiceTypeController = TextEditingController();
  final _paymentInstrumentInvoiceController = TextEditingController();
  final _ownerInvoiceController = TextEditingController();

  final _fixedExpenseFormKey = GlobalKey<FormState>();
  final _fixedExpenseIdController = TextEditingController();
  final _expenseTypeController = TextEditingController();
  final _paymentInstrumentFixedExpenseController = TextEditingController();
  final _detailsController = TextEditingController();


  @override
  initState() {
    super.initState();
    getUserUid();
  }


  @override
  Widget build(BuildContext context) {
    final _banks = Provider.of<List<Bank>>(context) ?? [];
    final _creditCards = Provider.of<List<CreditCard>>(context) ?? [];
    final _invoices = Provider.of<List<Invoice>>(context) ?? [];
    final _fixedExpenses = Provider.of<List<FixedExpense>>(context) ?? [];

    final _kTabs = <Tab>[
      Tab(
        icon: Icon(Icons.save),
        text: LocaleKeys.appStrings_dataInputItems_Banks.locale,
      ),
      Tab(
        icon: Icon(Icons.input),
        text: LocaleKeys.appStrings_dataInputItems_Credit_Cards.locale,
      ),
      Tab(
        icon: Icon(Icons.input),
        text: LocaleKeys.appStrings_dataInputItems_Fixed_Expenses.locale,
      ),
      Tab(
        icon: Icon(Icons.input),
        text: LocaleKeys.appStrings_dataInputItems_Invoices.locale,
      ),
    ];
    final _kTabPages = <Widget>[
      _bankTab(_banks),
      _creditCardTab(_creditCards, _banks),
      _fixedExpenseTab(_fixedExpenses, _creditCards, _banks),
      _invoiceTab(_invoices, _creditCards, _banks),
      
    ];

    return Scaffold(
      key: _scaffoldKeyDataInput,
      appBar: AppBar(
        title: Text(LocaleKeys.appStrings_dataInput.locale),
      ),
      backgroundColor: currentTheme.primaryColorLight,
      body: DefaultTabController(
        length: _kTabs.length,
        child: Scaffold(
          backgroundColor: currentTheme.primaryColorLight,
          appBar: TabBar(
            labelColor: Colors.blueGrey[800],
            unselectedLabelColor: Colors.blueGrey[200],
            indicatorColor: Colors.cyan,
            tabs: _kTabs,
          ),
          body: TabBarView(
            children: _kTabPages,
          ),
        ),
      ),
    );
  }

  Widget _getBankChip(_banks, _controller) {
    return Wrap(
      spacing: dynamicWidth(0.02),
      runSpacing: dynamicWidth(0.03),
      children: List<Widget>.generate(
        _banks.length,
        (int index) {
          return InputChip(
            labelPadding: EdgeInsets.all(dynamicWidth(0.01)),
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade600,
              child: Text(_banks[index].bankName[0].toUpperCase()),
            ),
            label: Text(
              _banks[index].bankName + ' / ' + _banks[index].accountType,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _controller.text = _banks[index].bankName;
              _scaffoldKeyDataInput.currentState.showSnackBar(SnackBar(
                content: Text("${_banks[index].bankName}"),
                duration: Duration(seconds: 1),
              ));
            },
            backgroundColor: currentTheme.colorScheme.background,
            elevation: 6.0,
            shadowColor: Colors.grey[60],
            padding: EdgeInsets.all(dynamicWidth(0.01)),
          );
        },
      ),
    );
  }

  Widget _getBankChipInvoice(_banks, _controller) {
    return Wrap(
      spacing: dynamicWidth(0.02),
      runSpacing: dynamicWidth(0.03),
      children: List<Widget>.generate(
        _banks.length,
        (int index) {
          return InputChip(
            labelPadding: EdgeInsets.all(dynamicWidth(0.01)),
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade600,
              child: Text(_banks[index].bankName[0].toUpperCase()),
            ),
            label: Text(
              _banks[index].bankName + ' / ' + _banks[index].accountType,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _controller.text =
                  _banks[index].bankName + ' / ' + _banks[index].accountType;
              _scaffoldKeyDataInput.currentState.showSnackBar(SnackBar(
                content: Text("${_banks[index].bankName}"),
                duration: Duration(seconds: 1),
              ));
            },
            backgroundColor: currentTheme.colorScheme.background,
            elevation: 6.0,
            shadowColor: Colors.grey[60],
            padding: EdgeInsets.all(dynamicWidth(0.01)),
          );
        },
      ),
    );
  }

  Widget _getCreditCardChip(_creditCards, _controller) {
    return Wrap(
      spacing: dynamicWidth(0.02),
      runSpacing: dynamicWidth(0.03),
      children: List<Widget>.generate(
        _creditCards.length,
        (int index) {
          return InputChip(
            labelPadding: EdgeInsets.all(dynamicWidth(0.01)),
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade600,
              child: Text(_creditCards[index].bankName[0].toUpperCase()),
            ),
            label: Text(
              _creditCards[index].bankName +
                  ' / ' +
                  _creditCards[index].cardType,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _controller.text = _creditCards[index].bankName +
                  '/' +
                  _creditCards[index].cardType;
              _scaffoldKeyDataInput.currentState.showSnackBar(SnackBar(
                content: Text(
                    "${_creditCards[index].bankName + ' ' + _creditCards[index].cardType}"),
                duration: Duration(seconds: 1),
              ));
            },
            backgroundColor: currentTheme.colorScheme.background,
            elevation: 6.0,
            shadowColor: Colors.grey[60],
            padding: EdgeInsets.all(dynamicWidth(0.01)),
          );
        },
      ),
    );
  }

  _bankTab(_banks) {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _bankFormKey,
              child: Padding(
                padding: EdgeInsets.all(dynamicWidth(0.02)),
                child: Column(
                  children: <Widget>[
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_bankName.locale),
                        controller: _bankNameBankController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterbankName.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_accountType.locale),
                        controller: _accountTypeController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterAccountType.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_owner.locale),
                        controller: _ownerBankController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterOwner.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_add.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_bankFormKey.currentState.validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result = await DatabaseBankService()
                                      .createBank(
                                          userUid,
                                          _bankNameBankController.text,
                                          _accountTypeController.text,
                                          _ownerBankController.text);
                                  if (result != null) {
                                    setState(() => loading = false);
                                  } else {
                                    setState(() => error =
                                        LocaleKeys.appStrings_errorCYI.locale);
                                    setState(() => loading = false);
                                  }
                                } catch (e) {}
                              }
                            },
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child:
                                Text(LocaleKeys.appStrings_clearScreen.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () {
                              setState(
                                () {
                                  _bankIdController.text = '';
                                  _bankNameBankController.text = '';
                                  _accountTypeController.text = '';
                                  _ownerBankController.text = '';
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_update.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_bankFormKey.currentState.validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result = await DatabaseBankService()
                                      .editBank(
                                          userUid,
                                          _bankIdController.text,
                                          _bankNameBankController.text,
                                          _accountTypeController.text,
                                          _ownerBankController.text);
                                  if (result != null) {
                                    setState(() => loading = false);
                                  } else {
                                    setState(() => error =
                                        LocaleKeys.appStrings_errorCYI.locale);
                                    setState(() => loading = false);
                                  }
                                } catch (e) {}
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: dynamicHeight(0.02),
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    Wrap(
                      spacing: dynamicWidth(0.02),
                      runSpacing: dynamicWidth(0.03),
                      children: List<Widget>.generate(
                        _banks.length,
                        (int index) {
                          return InputChip(
                            labelPadding: EdgeInsets.all(dynamicWidth(0.01)),
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade600,
                              child:
                                  Text(_banks[index].bankName[0].toUpperCase()),
                            ),
                            label: Text(
                              _banks[index].bankName +
                                  ' / ' +
                                  _banks[index].accountType +
                                  ' / ' +
                                  _banks[index].owner,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              _bankIdController.text = _banks[index].id;
                              _bankNameBankController.text = _banks[index].bankName;
                              _accountTypeController.text =
                                  _banks[index].accountType;
                              _ownerBankController.text = _banks[index].owner;
                            },
                            backgroundColor:
                                currentTheme.colorScheme.background,
                            elevation: 6.0,
                            shadowColor: Colors.grey[60],
                            padding: EdgeInsets.all(dynamicWidth(0.01)),
                            onDeleted: () async {
                              setState(() => loading = true);
                              await DatabaseBankService(
                                uid: userUid,
                              ).deleteBank(_banks[index].id);
                              setState(() => loading = false);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  _creditCardTab(_creditCards, _banks) {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _creditCardFormKey,
              child: Padding(
                padding: EdgeInsets.all(dynamicWidth(0.02)),
                child: Column(
                  children: <Widget>[
                    TextInputCard(
                      TextFormField(
                        enabled: false,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_bankName.locale),
                        controller: _bankNameCreditCardController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterbankName.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    _getBankChip(_banks, _bankNameCreditCardController),
                    SizedBox(height: dynamicHeight(0.01)),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_cardType.locale),
                        controller: _cardTypeController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterCardType.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_owner.locale),
                        controller: _ownerCreditCardController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterOwner.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_add.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_creditCardFormKey.currentState.validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result =
                                      await DatabaseCreditCardService()
                                          .createCreditCard(
                                              userUid,
                                              _bankNameCreditCardController.text,
                                              _cardTypeController.text,
                                              _ownerCreditCardController.text);
                                  if (result != null) {
                                    setState(() => loading = false);
                                  } else {
                                    setState(() => error =
                                        LocaleKeys.appStrings_errorCYI.locale);
                                    setState(() => loading = false);
                                  }
                                } catch (e) {}
                              }
                            },
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child:
                                Text(LocaleKeys.appStrings_clearScreen.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () {
                              setState(
                                () {
                                  _creditCardIdController.text = '';
                                  _bankNameCreditCardController.text = '';
                                  _cardTypeController.text = '';
                                  _ownerCreditCardController.text = '';
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_update.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_creditCardFormKey.currentState.validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result =
                                      await DatabaseCreditCardService()
                                          .editCreditCard(
                                              userUid,
                                              _creditCardIdController.text,
                                              _bankNameCreditCardController.text,
                                              _cardTypeController.text,
                                              _ownerCreditCardController.text);
                                  if (result != null) {
                                    setState(() => loading = false);
                                  } else {
                                    setState(() => error =
                                        LocaleKeys.appStrings_errorCYI.locale);
                                    setState(() => loading = false);
                                  }
                                } catch (e) {}
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: dynamicHeight(0.02),
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    Wrap(
                      spacing: dynamicWidth(0.02),
                      runSpacing: dynamicWidth(0.03),
                      children: List<Widget>.generate(
                        _creditCards.length,
                        (int index) {
                          return InputChip(
                            labelPadding: EdgeInsets.all(dynamicWidth(0.01)),
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade600,
                              child: Text(_creditCards[index]
                                  .bankName[0]
                                  .toUpperCase()),
                            ),
                            label: Text(
                              _creditCards[index].bankName +
                                  ' / ' +
                                  _creditCards[index].cardType +
                                  ' / ' +
                                  _creditCards[index].owner,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              _creditCardIdController.text =
                                  _creditCards[index].id;
                              _bankNameCreditCardController.text =
                                  _creditCards[index].bankName;
                              _cardTypeController.text =
                                  _creditCards[index].cardType;
                              _ownerCreditCardController.text = _creditCards[index].owner;
                            },
                            backgroundColor:
                                currentTheme.colorScheme.background,
                            elevation: 6.0,
                            shadowColor: Colors.grey[60],
                            padding: EdgeInsets.all(dynamicWidth(0.01)),
                            onDeleted: () async {
                              setState(() => loading = true);
                              await DatabaseCreditCardService(
                                uid: userUid,
                              ).deleteCreditCard(_creditCards[index].id);
                              setState(() => loading = false);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  _invoiceTab(_invoices, _creditCards, _banks) {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _invoiceFormKey,
              child: Padding(
                padding: EdgeInsets.all(dynamicWidth(0.02)),
                child: Column(
                  children: <Widget>[
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_invoiceType.locale),
                        controller: _incoiceTypeController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterInvoiceType.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        enabled: false,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_paymentInstrument.locale),
                        controller: _paymentInstrumentInvoiceController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterPaymentInstrument.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    _getCreditCardChip(
                        _creditCards, _paymentInstrumentInvoiceController),
                    SizedBox(height: dynamicHeight(0.01)),
                    _getBankChipInvoice(_banks, _paymentInstrumentInvoiceController),
                    SizedBox(height: dynamicHeight(0.01)),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_owner.locale),
                        controller: _ownerInvoiceController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterOwner.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_add.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_invoiceFormKey.currentState.validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result =
                                      await DatabaseInvoiceService()
                                          .createInvoice(
                                              userUid,
                                              _incoiceTypeController.text,
                                              _paymentInstrumentInvoiceController.text,
                                              _ownerInvoiceController.text);
                                  if (result != null) {
                                    setState(() => loading = false);
                                  } else {
                                    setState(() => error =
                                        LocaleKeys.appStrings_errorCYI.locale);
                                    setState(() => loading = false);
                                  }
                                } catch (e) {}
                              }
                            },
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child:
                                Text(LocaleKeys.appStrings_clearScreen.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () {
                              setState(
                                () {
                                  _invoiceIdController.text = '';
                                  _incoiceTypeController.text = '';
                                  _paymentInstrumentInvoiceController.text = '';
                                  _ownerInvoiceController.text = '';
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_update.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_invoiceFormKey.currentState.validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result =
                                      await DatabaseInvoiceService()
                                          .editInvoice(
                                              userUid,
                                              _invoiceIdController.text,
                                              _incoiceTypeController.text,
                                              _paymentInstrumentInvoiceController.text,
                                              _ownerInvoiceController.text);
                                  if (result != null) {
                                    setState(() => loading = false);
                                  } else {
                                    setState(() => error =
                                        LocaleKeys.appStrings_errorCYI.locale);
                                    setState(() => loading = false);
                                  }
                                } catch (e) {}
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: dynamicHeight(0.02),
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    Wrap(
                      spacing: dynamicWidth(0.02),
                      runSpacing: dynamicWidth(0.03),
                      children: List<Widget>.generate(
                        _invoices.length,
                        (int index) {
                          return InputChip(
                            labelPadding: EdgeInsets.all(dynamicWidth(0.01)),
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade600,
                              child: Text(_invoices[index]
                                  .invoiceType[0]
                                  .toUpperCase()),
                            ),
                            label: Text(
                              _invoices[index].invoiceType +
                                  ' / ' +
                                  _invoices[index].paymentInstrument +
                                  ' / ' +
                                  _invoices[index].owner,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              _invoiceIdController.text = _invoices[index].id;
                              _incoiceTypeController.text =
                                  _invoices[index].invoiceType;
                              _paymentInstrumentInvoiceController.text =
                                  _invoices[index].paymentInstrument;
                              _ownerInvoiceController.text = _invoices[index].owner;
                            },
                            backgroundColor:
                                currentTheme.colorScheme.background,
                            elevation: 6.0,
                            shadowColor: Colors.grey[60],
                            padding: EdgeInsets.all(dynamicWidth(0.01)),
                            onDeleted: () async {
                              setState(() => loading = true);
                              await DatabaseInvoiceService(
                                uid: userUid,
                              ).deleteInvoice(_invoices[index].id);
                              setState(() => loading = false);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  _fixedExpenseTab(_fixedExpenses, _creditCards, _banks) {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _fixedExpenseFormKey,
              child: Padding(
                padding: EdgeInsets.all(dynamicWidth(0.02)),
                child: Column(
                  children: <Widget>[
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_fixedExpenseType.locale),
                        controller: _expenseTypeController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterFixedExpenseType.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        enabled: false,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_paymentInstrument.locale),
                        controller: _paymentInstrumentFixedExpenseController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterPaymentInstrument.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    _getCreditCardChip(
                        _creditCards, _paymentInstrumentFixedExpenseController),
                    SizedBox(height: dynamicHeight(0.01)),
                    _getBankChipInvoice(_banks, _paymentInstrumentFixedExpenseController),
                    SizedBox(height: dynamicHeight(0.01)),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_details.locale),
                        controller: _detailsController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterDetails.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_add.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_fixedExpenseFormKey.currentState
                                  .validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result =
                                      await DatabaseFixedExpenseService()
                                          .createFixedExpense(
                                              userUid,
                                              _expenseTypeController.text,
                                              _paymentInstrumentFixedExpenseController.text,
                                              _detailsController.text);
                                  if (result != null) {
                                    setState(() => loading = false);
                                  } else {
                                    setState(() => error =
                                        LocaleKeys.appStrings_errorCYI.locale);
                                    setState(() => loading = false);
                                  }
                                } catch (e) {}
                              }
                            },
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child:
                                Text(LocaleKeys.appStrings_clearScreen.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () {
                              setState(
                                () {
                                  _fixedExpenseIdController.text = '';
                                  _expenseTypeController.text = '';
                                  _paymentInstrumentFixedExpenseController.text = '';
                                  _detailsController.text = '';
                                },
                              );
                            },
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_update.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_fixedExpenseFormKey.currentState
                                  .validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result =
                                      await DatabaseFixedExpenseService()
                                          .editFixedExpense(
                                              userUid,
                                              _fixedExpenseIdController.text,
                                              _expenseTypeController.text,
                                              _paymentInstrumentFixedExpenseController.text,
                                              _detailsController.text);
                                  if (result != null) {
                                    setState(() => loading = false);
                                  } else {
                                    setState(() => error =
                                        LocaleKeys.appStrings_errorCYI.locale);
                                    setState(() => loading = false);
                                  }
                                } catch (e) {}
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: dynamicHeight(0.02),
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    Wrap(
                      spacing: dynamicWidth(0.02),
                      runSpacing: dynamicWidth(0.03),
                      children: List<Widget>.generate(
                        _fixedExpenses.length,
                        (int index) {
                          return InputChip(
                            labelPadding: EdgeInsets.all(dynamicWidth(0.01)),
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade600,
                              child: Text(_fixedExpenses[index]
                                  .expenseType[0]
                                  .toUpperCase()),
                            ),
                            label: Text(
                              _fixedExpenses[index].expenseType +
                                  ' / ' +
                                  _fixedExpenses[index].paymentInstrument +
                                  ' / ' +
                                  _fixedExpenses[index].details,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              _fixedExpenseIdController.text =
                                  _fixedExpenses[index].id;
                              _expenseTypeController.text =
                                  _fixedExpenses[index].expenseType;
                              _paymentInstrumentFixedExpenseController.text =
                                  _fixedExpenses[index].paymentInstrument;
                              _detailsController.text =
                                  _fixedExpenses[index].details;
                            },
                            backgroundColor:
                                currentTheme.colorScheme.background,
                            elevation: 6.0,
                            shadowColor: Colors.grey[60],
                            padding: EdgeInsets.all(dynamicWidth(0.01)),
                            onDeleted: () async {
                              setState(() => loading = true);
                              await DatabaseFixedExpenseService(
                                uid: userUid,
                              ).deleteFixedExpense(_fixedExpenses[index].id);
                              setState(() => loading = false);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
