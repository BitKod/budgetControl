import 'package:budgetControl/core/init/locale_keys.g.dart';
import 'package:budgetControl/core/init/string_extensions.dart';
import 'package:budgetControl/inApp/services/database_expense.dart';
import 'package:budgetControl/inApp/services/database_income.dart';
import 'package:budgetControl/inApp/services/database_saving.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../core/view/base/base_state.dart';
import '../../core/view/widget/card/text_input_card.dart';
import '../../core/view/widget/loading/loading.dart';
import '../models/bank.dart';
import '../models/credit_card.dart';
import '../models/fixed_expense.dart';
import '../models/invoice.dart';

class Operation extends StatefulWidget {
  const Operation({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _OperationState();
}

class _OperationState extends BaseState<Operation> {
  final GlobalKey<ScaffoldState> _scaffoldKeyOperation =
      new GlobalKey<ScaffoldState>();

  final _incomeFormKey = GlobalKey<FormState>();
  final _incomeIdController = TextEditingController();
  final _bankNameIncomeController = TextEditingController();
  final _incomeTypeController = TextEditingController();
  final _incomeAmountController = TextEditingController();
  final _periodMonthIncomeController = TextEditingController();
  final _periodYearIncomeController = TextEditingController();

  final _expenseFormKey = GlobalKey<FormState>();
  final _expenseIdController = TextEditingController();
  final _bankNameExpenseController = TextEditingController();
  final _expenseTypeController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  final _installmentPeriodController = TextEditingController();
  final _expenseInstrumentController = TextEditingController();
  final _expenseDetailController = TextEditingController();
  final _periodMonthExpenseController = TextEditingController();
  final _periodYearExpenseController = TextEditingController();

  final _savingFormKey = GlobalKey<FormState>();
  final _savingIdController = new TextEditingController();
  final _bankNameSavingController = new TextEditingController();
  final _savingTypeController = new TextEditingController();
  final _savingAmountController = new TextEditingController();
  final _savingCurrencyController = new TextEditingController();
  final _savingDateController = new TextEditingController();

  bool installmentStatus = false;
  bool fixedExpenseStatus = false;
  bool otherExpenseStatus = false;
  bool invoiceStatus = false;

  DateTime currentDate;
  DateTime selectedDate;

  String _selectedExpenseType;

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
      Tab(icon: Icon(Icons.save), text: LocaleKeys.appStrings_incomes.locale),
      Tab(icon: Icon(Icons.input), text: LocaleKeys.appStrings_expenses.locale),
      Tab(icon: Icon(Icons.input), text: LocaleKeys.appStrings_savings.locale),
    ];
    final _kTabPages = <Widget>[
      _incomeTab(_banks),
      _expensesTab(_creditCards, _banks, _fixedExpenses, _invoices),
      _savingTab(_banks),
    ];

    return Scaffold(
      key: _scaffoldKeyOperation,
      appBar: AppBar(
        title: Text(LocaleKeys.appStrings_operations.locale),
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

  _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2025));
    if (picked != null) {
      String dmy = picked.day.toString() +
          '/' +
          picked.month.toString() +
          '/' +
          picked.year.toString();
      return dmy;
    } else {
      return '';
    }
  }

  _getBankChip(_banks, _controller) {
    return Wrap(
      spacing: dynamicWidth(0.02),
      runSpacing: dynamicWidth(0.01),
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
              _banks[index].bankName + '/' + _banks[index].accountType,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _controller.text = _banks[index].bankName;
              _scaffoldKeyOperation.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                content: Text(
                    "${_banks[index].bankName + '/' + _banks[index].accountType}"),
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

  _getBankChipOther(_banks, _bankNameController, _expenseIntrumentController) {
    return Wrap(
      spacing: dynamicWidth(0.02),
      runSpacing: dynamicWidth(0.01),
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
              _banks[index].bankName + '/' + _banks[index].accountType,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _bankNameController.text = _banks[index].bankName;
              _expenseIntrumentController.text = _banks[index].accountType;
              _scaffoldKeyOperation.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                content: Text(
                    "${_banks[index].bankName + '/' + _banks[index].accountType}"),
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

  _getBankChipSaving(_banks, _bankNameController, _savingTypeController) {
    return Wrap(
      spacing: dynamicWidth(0.02),
      runSpacing: dynamicWidth(0.01),
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
              _banks[index].bankName + '/' + _banks[index].accountType,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _bankNameController.text = _banks[index].bankName;
              _savingTypeController.text = _banks[index].accountType;
              _scaffoldKeyOperation.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                content: Text(
                    "${_banks[index].bankName + '/' + _banks[index].accountType}"),
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

  _getCreditCardChip(
      _creditCards, _bankNameController, _expenseInstrumentController) {
    return Wrap(
      spacing: dynamicWidth(0.02),
      runSpacing: dynamicWidth(0.01),
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
              _creditCards[index].bankName + '_' + _creditCards[index].cardType,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _bankNameController.text = _creditCards[index].bankName;
              _expenseInstrumentController.text = _creditCards[index].cardType;
              _scaffoldKeyOperation.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
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

  _getFixedExpenseChip(_fixedExpenses, _bankNameController,
      _expenseInstrumentController, _expenseTypeController) {
    return Wrap(
      spacing: dynamicWidth(0.02),
      runSpacing: dynamicWidth(0.01),
      children: List<Widget>.generate(
        _fixedExpenses.length,
        (int index) {
          return InputChip(
            labelPadding: EdgeInsets.all(dynamicWidth(0.01)),
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade600,
              child: Text(
                  _fixedExpenses[index].paymentInstrument[0].toUpperCase()),
            ),
            label: Text(
              _fixedExpenses[index].details,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _expenseInstrumentController.text =
                  _fixedExpenses[index].paymentInstrument.split("/")[1];
              _bankNameController.text =
                  _fixedExpenses[index].paymentInstrument.split("/")[0];
              _expenseTypeController.text = _selectedExpenseType;
              _scaffoldKeyOperation.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                content: Text(
                  _expenseTypeController.text,
                ),
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

  _getInvoiceChip(
      _invoices, _bankNameController, _expenseInstrumentController) {
    return Wrap(
      spacing: dynamicWidth(0.02),
      runSpacing: dynamicWidth(0.01),
      children: List<Widget>.generate(
        _invoices.length,
        (int index) {
          return InputChip(
            labelPadding: EdgeInsets.all(dynamicWidth(0.01)),
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade600,
              child: Text(_invoices[index].paymentInstrument[0].toUpperCase()),
            ),
            label: Text(
              _invoices[index].invoiceType + '/' + _invoices[index].owner,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _expenseInstrumentController.text =
                  _invoices[index].paymentInstrument.split("/")[1];
              _bankNameController.text =
                  _invoices[index].paymentInstrument.split("/")[0];
              _scaffoldKeyOperation.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                content: Text("${_invoices[index].paymentInstrument}"),
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

  _getExpenseTypeRadio(_expenseTypeController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(LocaleKeys.appStrings_expenseTypesList_Installment.locale),
            new Radio(
              onChanged: (value) {
                _expenseTypeController.text = value;

                setState(
                  () {
                    installmentStatus = true;
                    fixedExpenseStatus = false;
                    invoiceStatus = false;
                    otherExpenseStatus = false;
                    _selectedExpenseType = value;
                  },
                );
              },
              groupValue: _selectedExpenseType,
              value: LocaleKeys.appStrings_expenseTypesList_Installment.locale,
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Text(LocaleKeys.appStrings_expenseTypesList_Fixed_Expense.locale),
            new Radio(
              onChanged: (value) {
                _expenseTypeController.text = value;

                setState(
                  () {
                    installmentStatus = false;
                    fixedExpenseStatus = true;
                    invoiceStatus = false;
                    otherExpenseStatus = false;
                    _selectedExpenseType = value;
                  },
                );
              },
              groupValue: _selectedExpenseType,
              value:
                  LocaleKeys.appStrings_expenseTypesList_Fixed_Expense.locale,
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Text(LocaleKeys.appStrings_expenseTypesList_Invoice.locale),
            new Radio(
              onChanged: (value) {
                _expenseTypeController.text = value;

                setState(
                  () {
                    installmentStatus = false;
                    fixedExpenseStatus = false;
                    invoiceStatus = true;
                    otherExpenseStatus = false;
                    _selectedExpenseType = value;
                  },
                );
              },
              groupValue: _selectedExpenseType,
              value: LocaleKeys.appStrings_expenseTypesList_Invoice.locale,
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Text(LocaleKeys.appStrings_expenseTypesList_Other.locale),
            new Radio(
              onChanged: (value) {
                _expenseTypeController.text = value;

                setState(
                  () {
                    installmentStatus = false;
                    fixedExpenseStatus = false;
                    invoiceStatus = false;
                    otherExpenseStatus = true;
                    _selectedExpenseType = value;
                  },
                );
              },
              groupValue: _selectedExpenseType,
              value: LocaleKeys.appStrings_expenseTypesList_Other.locale,
            ),
          ],
        ),
      ],
    );
  }

  _getMonthYear(_controllerMonth, _controllerYear) {
    return RaisedButton(
      child: Text(LocaleKeys.appStrings_selectDate.locale),
      color: currentTheme.primaryColor,
      textColor: Colors.white,
      onPressed: () {
        showMonthPicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().year - 3, 12),
          lastDate: DateTime(DateTime.now().year + 5, 12),
        ).then(
          (date) {
            if (date != null) {
              _controllerMonth.text = date.month.toString();
              _controllerYear.text = date.year.toString();
              _scaffoldKeyOperation.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                content:
                    Text("${_controllerMonth.text} / ${_controllerYear.text}"),
                duration: Duration(seconds: 1),
              ));
            }
          },
        );
      },
    );
  }

  _incomeTab(_banks) {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _incomeFormKey,
              child: Padding(
                padding: EdgeInsets.all(dynamicWidth(0.02)),
                child: Column(
                  children: <Widget>[
                    TextInputCard(
                      TextFormField(
                        enabled: false,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_bankName.locale),
                        controller: _bankNameIncomeController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterbankName.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    _getBankChip(_banks, _bankNameIncomeController),
                    SizedBox(height: dynamicHeight(0.01)),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_incomeType.locale),
                        controller: _incomeTypeController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterIncomeType.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_incomeAmount.locale),
                        controller: _incomeAmountController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterIncomeAmount.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: dynamicWidth(0.4),
                          child: TextInputCard(
                            TextFormField(
                              enabled: false,
                              decoration: appConstants.textInputDecoration
                                  .copyWith(
                                      labelText: LocaleKeys
                                          .appStrings_periodMonth.locale),
                              controller: _periodMonthIncomeController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return LocaleKeys
                                      .appStrings_periodMonth.locale;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: dynamicWidth(0.4),
                          child: TextInputCard(
                            TextFormField(
                              enabled: false,
                              decoration: appConstants.textInputDecoration
                                  .copyWith(
                                      labelText: LocaleKeys
                                          .appStrings_periodYear.locale),
                              controller: _periodYearIncomeController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return LocaleKeys
                                      .appStrings_periodYear.locale;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    _getMonthYear(_periodMonthIncomeController,
                        _periodYearIncomeController),
                    SizedBox(height: dynamicHeight(0.01)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_add.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_incomeFormKey.currentState.validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result = await DatabaseIncomeService()
                                      .createIncome(
                                    userUid,
                                    _bankNameIncomeController.text,
                                    _incomeTypeController.text,
                                    _incomeAmountController.text
                                        .replaceAll(RegExp(','), '.'),
                                    _periodMonthIncomeController.text,
                                    _periodYearIncomeController.text,
                                  );
                                  if (result != null) {
                                    _scaffoldKeyOperation.currentState
                                        .showSnackBar(SnackBar(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      content: Text(LocaleKeys
                                          .appStrings_operationCompleted
                                          .locale),
                                      duration: Duration(seconds: 1),
                                    ));
                                    setState(() => loading = false);
                                    _incomeIdController.text = '';
                                    _bankNameIncomeController.text = '';
                                    _incomeTypeController.text = '';
                                    _incomeAmountController.text = '';
                                    _periodMonthIncomeController.text = '';
                                    _periodYearIncomeController.text = '';
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
                              _incomeFormKey.currentState.reset();
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
                  ],
                ),
              ),
            ),
          );
  }

  _expensesTab(_creditCards, _banks, _fixedExpenses, _invoices) {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _expenseFormKey,
              child: Padding(
                padding: EdgeInsets.all(dynamicWidth(0.02)),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(dynamicWidth(0.01)),
                      child: Text(
                        LocaleKeys.appStrings_expenseType.locale,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: dynamicHeight(0.01)),
                    _getExpenseTypeRadio(_expenseTypeController),
                    SizedBox(height: dynamicHeight(0.01)),
                    if (fixedExpenseStatus) ...[
                      _getFixedExpenseChip(
                          _fixedExpenses,
                          _bankNameExpenseController,
                          _expenseInstrumentController,
                          _expenseTypeController),
                      SizedBox(height: dynamicHeight(0.01)),
                    ],
                    if (invoiceStatus) ...[
                      _getInvoiceChip(_invoices, _bankNameExpenseController,
                          _expenseInstrumentController),
                      SizedBox(height: dynamicHeight(0.01)),
                    ],
                    if (installmentStatus) ...[
                      _getCreditCardChip(
                          _creditCards,
                          _bankNameExpenseController,
                          _expenseInstrumentController),
                      SizedBox(height: dynamicHeight(0.01)),
                      TextInputCard(
                        TextFormField(
                          decoration: appConstants.textInputDecoration.copyWith(
                              labelText: LocaleKeys
                                  .appStrings_installmentPeriod.locale),
                          controller: _installmentPeriodController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return LocaleKeys
                                  .appStrings_enterInstallmentPeriod.locale;
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: dynamicHeight(0.01)),
                    ],
                    if (otherExpenseStatus) ...[
                      TextInputCard(
                        TextFormField(
                          enabled: false,
                          decoration: appConstants.textInputDecoration.copyWith(
                              labelText: LocaleKeys
                                  .appStrings_expenseInstrument.locale),
                          controller: _expenseInstrumentController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return LocaleKeys
                                  .appStrings_enterExpenseInstrument.locale;
                            }
                            return null;
                          },
                        ),
                      ),
                      _getBankChipOther(_banks, _bankNameExpenseController,
                          _expenseInstrumentController),
                      _getCreditCardChip(
                          _creditCards,
                          _bankNameExpenseController,
                          _expenseInstrumentController),
                      SizedBox(height: dynamicHeight(0.01)),
                    ],
                    TextInputCard(
                      TextFormField(
                        enabled: false,
                        keyboardType: TextInputType.number,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_bankName.locale),
                        controller: _bankNameExpenseController,
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
                        enabled: false,
                        keyboardType: TextInputType.number,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_expenseInstrument.locale),
                        controller: _expenseInstrumentController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterExpenseInstrument.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_expenseAmount.locale),
                        controller: _expenseAmountController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterExpenseAmount.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_expenseDetail.locale),
                        controller: _expenseDetailController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterExpenseDetail.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: dynamicWidth(0.4),
                          child: TextInputCard(
                            TextFormField(
                              enabled: false,
                              decoration: appConstants.textInputDecoration
                                  .copyWith(
                                      labelText: LocaleKeys
                                          .appStrings_periodMonth.locale),
                              controller: _periodMonthExpenseController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return LocaleKeys
                                      .appStrings_enterPeriodMonth.locale;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: dynamicWidth(0.4),
                          child: TextInputCard(
                            TextFormField(
                              enabled: false,
                              decoration: appConstants.textInputDecoration
                                  .copyWith(
                                      labelText: LocaleKeys
                                          .appStrings_periodYear.locale),
                              controller: _periodYearExpenseController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return LocaleKeys
                                      .appStrings_enterPeriodYear.locale;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    _getMonthYear(_periodMonthExpenseController,
                        _periodYearExpenseController),
                    SizedBox(height: dynamicHeight(0.01)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_add.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_expenseFormKey.currentState.validate()) {
                                setState(() => loading = true);
                                if (!installmentStatus) {
                                  _installmentPeriodController.text = '1';
                                }

                                if (otherExpenseStatus) {
                                  _selectedExpenseType = _selectedExpenseType;
                                }

                                try {
                                  dynamic result =
                                      await DatabaseExpenseService()
                                          .createExpense(
                                    userUid,
                                    _bankNameExpenseController.text,
                                    _selectedExpenseType,
                                    _expenseAmountController.text
                                        .replaceAll(RegExp(','), '.'),
                                    _installmentPeriodController.text,
                                    _expenseInstrumentController.text,
                                    _periodMonthExpenseController.text,
                                    _periodYearExpenseController.text,
                                  );
                                  if (result != null) {
                                    _scaffoldKeyOperation.currentState
                                        .showSnackBar(SnackBar(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      content: Text(LocaleKeys
                                          .appStrings_operationCompleted
                                          .locale),
                                      duration: Duration(seconds: 1),
                                    ));

                                    setState(() => loading = false);

                                    _expenseIdController.text = '';
                                    _bankNameExpenseController.text = '';
                                    _expenseTypeController.text = '';
                                    _expenseAmountController.text = '';
                                    _installmentPeriodController.text = '';
                                    _expenseInstrumentController.text = '';
                                    _periodMonthExpenseController.text = '';
                                    _periodYearExpenseController.text = '';
                                    _selectedExpenseType = '';
                                    installmentStatus = false;
                                    fixedExpenseStatus = false;
                                    invoiceStatus = false;
                                    otherExpenseStatus = false;
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
                              _expenseFormKey.currentState.reset();
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
                  ],
                ),
              ),
            ),
          );
  }

  _savingTab(_banks) {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _savingFormKey,
              child: Padding(
                padding: EdgeInsets.all(dynamicWidth(0.02)),
                child: Column(
                  children: <Widget>[
                    TextInputCard(
                      TextFormField(
                        enabled: false,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_bankName.locale),
                        controller: _bankNameSavingController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterbankName.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    _getBankChipSaving(_banks, _bankNameSavingController,
                        _savingTypeController),
                    SizedBox(height: dynamicHeight(0.01)),
                    TextInputCard(
                      TextFormField(
                        enabled: false,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_savingType.locale),
                        controller: _savingTypeController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterSavingType.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_savingAmount.locale),
                        controller: _savingAmountController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterSavingAmount.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_savingCurrency.locale),
                        controller: _savingCurrencyController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys
                                .appStrings_enterSavingCurrency.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        _savingDateController.text = await _selectDate();
                      },
                      child: IgnorePointer(
                        child: new TextFormField(
                          decoration: appConstants.textInputDecoration.copyWith(
                              labelText:
                                  LocaleKeys.appStrings_savingDate.locale),
                          controller: _savingDateController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return LocaleKeys
                                  .appStrings_enterSavingDate.locale;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                            child: Text(LocaleKeys.appStrings_add.locale),
                            color: currentTheme.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_savingFormKey.currentState.validate()) {
                                setState(() => loading = true);
                                try {
                                  dynamic result = await DatabaseSavingService()
                                      .createSaving(
                                    userUid,
                                    _bankNameSavingController.text,
                                    _savingTypeController.text,
                                    _savingAmountController.text
                                        .replaceAll(RegExp(','), '.'),
                                    _savingCurrencyController.text
                                        .replaceAll(RegExp(','), '.'),
                                    _savingDateController.text,
                                  );
                                  if (result != null) {
                                    _scaffoldKeyOperation.currentState
                                        .showSnackBar(SnackBar(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      content: Text(LocaleKeys
                                          .appStrings_operationCompleted
                                          .locale),
                                      duration: Duration(seconds: 1),
                                    ));
                                    setState(() => loading = false);
                                    _savingIdController.text = '';
                                    _bankNameSavingController.text = '';
                                    _savingTypeController.text = '';
                                    _savingAmountController.text = '';
                                    _savingCurrencyController.text = '';
                                    _savingDateController.text = '';
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
                              _savingFormKey.currentState.reset();
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
                  ],
                ),
              ),
            ),
          );
  }
}
