import 'package:budgetControl/core/init/locale_keys.g.dart';
import 'package:budgetControl/core/init/string_extensions.dart';
import 'package:budgetControl/core/view/base/base_state.dart';
import 'package:budgetControl/core/view/widget/card/text_input_card.dart';
import 'package:budgetControl/core/view/widget/loading/loading.dart';
import 'package:budgetControl/inApp/models/expense.dart';
import 'package:budgetControl/inApp/services/auth.dart';
import 'package:budgetControl/inApp/services/database_expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Expenses extends StatefulWidget {
  const Expenses({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExpensesState();
}

class _ExpensesState extends BaseState<Expenses> {
  final GlobalKey<ScaffoldState> _scaffoldKeyExpenses =
      new GlobalKey<ScaffoldState>();

  final AuthService _auth = AuthService();
  String userUid;
  List<Expense> _expenses = [];

  initState() {
    getUserUid();
    super.initState();
  }

  getUserUid() async {
    String _userUid = await _auth.currentUserUid;
    setState(
      () {
        userUid = _userUid;
      },
    );
  }

  bool installmentStatus = false;
  bool fixedExpenseStatus = false;
  bool otherExpenseStatus = false;
  bool invoiceStatus = false;

  String _selectedExpenseType;

  String _bankName;
  String _expenseType;
  String _expenseInstrument;
  String _periodMonth;
  String _periodYear;
  double _sumOfExpense = 0.0;

  final _expenseFormKey = GlobalKey<FormState>();
  final _expenseIdController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _expenseTypeController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  final _installmentPeriodController = TextEditingController();
  final _expenseInstrumentController = TextEditingController();
  final _expenseDetailController = TextEditingController();
  final _periodMonthController = TextEditingController();
  final _periodYearController = TextEditingController();
  final _expenseOtherController = TextEditingController();

  @override
  void dispose() {
    _expenseIdController.dispose();
    _bankNameController.dispose();
    _expenseTypeController.dispose();
    _expenseAmountController.dispose();
    _installmentPeriodController.dispose();
    _expenseInstrumentController.dispose();
    _expenseDetailController.dispose();
    _periodMonthController.dispose();
    _periodYearController.dispose();
    _expenseOtherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyExpenses,
      appBar: AppBar(
        title: Text(LocaleKeys.appStrings_expenses.locale),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseExpenseService().getFilteredExpenses(userUid, _bankName,
            _expenseType, _expenseInstrument, _periodMonth, _periodYear),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Loading();
            default:
              _expenses = snapshot.data.documents.map((doc) {
                return Expense.fromFirestore(doc);
              }).toList();

              _sumOfExpense = 0.0;

              for (var i = 0; i < _expenses.length; i++) {
                _sumOfExpense =
                    _sumOfExpense + double.parse(_expenses[i].expenseAmount);
              }

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: <Widget>[
                        DropdownButton(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentTheme.primaryColorDark,
                          ),
                          value: _bankName,
                          hint: Text(LocaleKeys.appStrings_bankName.locale),
                          onChanged: ((String newValue) {
                            setState(() {
                              _bankName = newValue;
                            });
                          }),
                          items: _expenses
                              .map((f) => f.bankName)
                              .toSet()
                              .toList()
                              .map(
                                (bankName) => DropdownMenuItem<String>(
                                  value: bankName,
                                  child: Text(bankName),
                                ),
                              )
                              .toList(),
                        ),
                        _getMonthYear(),
                        Wrap(
                          children: <Widget>[
                            DropdownButton(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: currentTheme.primaryColorDark,
                              ),
                              value: _expenseType,
                              hint: Text(
                                  LocaleKeys.appStrings_expenseType.locale),
                              onChanged: ((String newValue) {
                                setState(() {
                                  _expenseType = newValue;
                                });
                              }),
                              items: _expenses
                                  .toList()
                                  .map((f) => f.expenseType)
                                  .toSet()
                                  .toList()
                                  .map(
                                    (expenseType) => DropdownMenuItem<String>(
                                      value: expenseType,
                                      child: Text(expenseType),
                                    ),
                                  )
                                  .toList(),
                            ),
                            DropdownButton(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: currentTheme.primaryColorDark,
                              ),
                              value: _expenseInstrument,
                              hint: Text(LocaleKeys
                                  .appStrings_expenseInstrument.locale),
                              onChanged: ((String newValue) {
                                setState(() {
                                  _expenseInstrument = newValue;
                                });
                              }),
                              items: _expenses
                                  .map((f) => f.expenseInstrument)
                                  .toSet()
                                  .toList()
                                  .map(
                                    (expenseInstrument) =>
                                        DropdownMenuItem<String>(
                                      value: expenseInstrument,
                                      child: Text(expenseInstrument),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Center(
                      child: RaisedButton(
                        child: Text(LocaleKeys.appStrings_clearFilters.locale),
                        color: currentTheme.primaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _bankName = null;
                            _expenseType = null;
                            _expenseInstrument = null;
                            _periodMonth = null;
                            _periodYear = null;
                          });
                          _scaffoldKeyExpenses.currentState.showSnackBar(
                            SnackBar(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              content: Text(
                                  LocaleKeys.appStrings_filtersCleared.locale),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        dynamicWidth(0.1),
                        dynamicHeight(0.005),
                        dynamicWidth(0.1),
                        dynamicHeight(0.001),
                      ),
                      child: Container(
                        color: currentTheme.primaryColor,
                        height: dynamicHeight(0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              LocaleKeys.appStrings_sumOfExpense.locale + ' ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _sumOfExpense.toStringAsFixed(2),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(
                        dynamicWidth(0.05),
                        dynamicHeight(0.005),
                        dynamicWidth(0.05),
                        dynamicHeight(0.001),
                      ),
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        Expense _expense = _expenses[index];
                        return Dismissible(
                          key: Key(_expense.id),
                          background: slideRightBackground(),
                          secondaryBackground: slideLeftBackground(),
                          child: Card(
                            color: currentTheme.primaryColor,
                            margin: EdgeInsets.fromLTRB(
                              dynamicWidth(0.05),
                              dynamicHeight(0.005),
                              dynamicWidth(0.05),
                              dynamicHeight(0.01),
                            ),
                            elevation: 0.5,
                            child: InkWell(
                              splashColor: currentTheme.primaryColorLight,
                              onTap: () {},
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        _expenses[index].bankName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _expenses[index].expenseAmount,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Text(
                                        _expenses[index].expenseType,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              final bool res = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          currentTheme.primaryColorLight,
                                      content: Text(
                                          "${LocaleKeys.appStrings_deleteConfirmation.locale} ${_expenses[index].expenseType} / ${_expenses[index].expenseInstrument}?"),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            LocaleKeys.appStrings_cancel.locale,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                            child: Text(
                                              LocaleKeys
                                                  .appStrings_delete.locale,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () async {
                                              try {
                                                dynamic result =
                                                    await DatabaseExpenseService()
                                                        .deleteExpense(
                                                  userUid,
                                                  _expenseIdController.text,
                                                );
                                                if (result != null) {
                                                  setState(
                                                      () => loading = false);
                                                  Navigator.pop(context);
                                                  _scaffoldKeyExpenses
                                                      .currentState
                                                      .showSnackBar(SnackBar(
                                                    content: Text(LocaleKeys
                                                        .appStrings_expenseDeleted
                                                        .locale),
                                                    duration:
                                                        Duration(seconds: 1),
                                                  ));
                                                } else {
                                                  setState(() => error =
                                                      LocaleKeys
                                                          .appStrings_errorCYI
                                                          .locale);
                                                }
                                              } catch (e) {}
                                            }),
                                      ],
                                    );
                                  });
                            } else {
                              _expenseIdController.text = _expense.id;
                              _bankNameController.text = _expense.bankName;
                              _expenseTypeController.text =
                                  _expense.expenseType;
                              _expenseAmountController.text =
                                  _expense.expenseAmount;
                              _installmentPeriodController.text =
                                  _expense.installmentPeriod;
                              _expenseInstrumentController.text =
                                  _expense.expenseInstrument;
                              _periodMonthController.text =
                                  _expense.periodMonth;
                              _periodYearController.text = _expense.periodYear;
                              setState(() {
                                _selectedExpenseType = _expense.expenseType;
                              });

                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => SimpleDialog(
                                  elevation: 10.0,
                                  backgroundColor:
                                      currentTheme.primaryColorLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                      color: currentTheme.primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                      LocaleKeys.appStrings_editExpense.locale),
                                  children: <Widget>[
                                    loading
                                        ? Loading()
                                        : SingleChildScrollView(
                                            child: Form(
                                              key: _expenseFormKey,
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    dynamicWidth(0.02)),
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 16.0,
                                                              bottom: 16.0),
                                                      child: RaisedButton(
                                                        child: Text(LocaleKeys
                                                            .appStrings_edit
                                                            .locale),
                                                        color: currentTheme
                                                            .primaryColor,
                                                        textColor: Colors.white,
                                                        onPressed: () async {
                                                          if (_expenseFormKey
                                                              .currentState
                                                              .validate()) {
                                                            setState(() =>
                                                                loading = true);
                                                            try {
                                                              dynamic result =
                                                                  await DatabaseExpenseService()
                                                                      .editExpense(
                                                                userUid,
                                                                _expenseIdController
                                                                    .text,
                                                                _bankNameController
                                                                    .text,
                                                                _expenseTypeController
                                                                    .text,
                                                                _expenseAmountController
                                                                    .text
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            ','),
                                                                        '.'),
                                                                _installmentPeriodController
                                                                    .text,
                                                                _expenseInstrumentController
                                                                    .text,
                                                                _periodMonthController
                                                                    .text,
                                                                _periodYearController
                                                                    .text,
                                                              );
                                                              if (result !=
                                                                  null) {
                                                                setState(() =>
                                                                    loading =
                                                                        false);
                                                                Navigator.pop(
                                                                    context);
                                                                _scaffoldKeyExpenses
                                                                    .currentState
                                                                    .showSnackBar(
                                                                        SnackBar(
                                                                  content: Text(
                                                                      LocaleKeys
                                                                          .appStrings_expenseEdited
                                                                          .locale),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              1),
                                                                ));
                                                              } else {
                                                                setState(() => error =
                                                                    LocaleKeys
                                                                        .appStrings_errorCYI
                                                                        .locale);
                                                                setState(() =>
                                                                    loading =
                                                                        false);
                                                              }
                                                            } catch (e) {}
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    TextInputCard(
                                                      TextFormField(
                                                        enabled: false,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration: appConstants
                                                            .textInputDecoration
                                                            .copyWith(
                                                                labelText: LocaleKeys
                                                                    .appStrings_bankName
                                                                    .locale),
                                                        controller:
                                                            _bankNameController,
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return LocaleKeys
                                                                .appStrings_enterbankName
                                                                .locale;
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    TextInputCard(
                                                      TextFormField(
                                                        enabled: false,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration: appConstants
                                                            .textInputDecoration
                                                            .copyWith(
                                                                labelText: LocaleKeys
                                                                    .appStrings_expenseInstrument
                                                                    .locale),
                                                        controller:
                                                            _expenseInstrumentController,
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return LocaleKeys
                                                                .appStrings_enterExpenseInstrument
                                                                .locale;
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    TextInputCard(
                                                      TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration: appConstants
                                                            .textInputDecoration
                                                            .copyWith(
                                                                labelText: LocaleKeys
                                                                    .appStrings_expenseAmount
                                                                    .locale),
                                                        controller:
                                                            _expenseAmountController,
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return LocaleKeys
                                                                .appStrings_enterExpenseAmount
                                                                .locale;
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width:
                                                              dynamicWidth(0.3),
                                                          child: TextInputCard(
                                                            TextFormField(
                                                              enabled: false,
                                                              decoration: appConstants
                                                                  .textInputDecoration
                                                                  .copyWith(
                                                                      labelText: LocaleKeys
                                                                          .appStrings_periodMonth
                                                                          .locale),
                                                              controller:
                                                                  _periodMonthController,
                                                              validator:
                                                                  (value) {
                                                                if (value
                                                                    .isEmpty) {
                                                                  return LocaleKeys
                                                                      .appStrings_enterPeriodMonth
                                                                      .locale;
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              dynamicWidth(0.3),
                                                          child: TextInputCard(
                                                            TextFormField(
                                                              enabled: false,
                                                              decoration: appConstants
                                                                  .textInputDecoration
                                                                  .copyWith(
                                                                      labelText: LocaleKeys
                                                                          .appStrings_periodYear
                                                                          .locale),
                                                              controller:
                                                                  _periodYearController,
                                                              validator:
                                                                  (value) {
                                                                if (value
                                                                    .isEmpty) {
                                                                  return LocaleKeys
                                                                      .appStrings_enterPeriodYear
                                                                      .locale;
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    _getMonthYearEdit(
                                                        _periodMonthController,
                                                        _periodYearController),
                                                    SizedBox(
                                                      height:
                                                          dynamicHeight(0.02),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          dynamicHeight(0.02),
                                                    ),
                                                    Text(
                                                      error,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 14.0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ).then((returnVal) {
                                if (returnVal != null) {
                                  _scaffoldKeyExpenses.currentState
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text('$returnVal'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              });
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  _getMonthYear() {
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
              setState(() {
                _periodMonth = date.month.toString();
                _periodYear = date.year.toString();
              });
              _scaffoldKeyExpenses.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                content: Text("${_periodMonth} / ${_periodYear}"),
                duration: Duration(seconds: 1),
              ));
            }
          },
        );
      },
    );
  }

  _getMonthYearEdit(_controllerMonth, _controllerYear) {
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
            }
          },
        );
      },
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              ' ' + LocaleKeys.appStrings_edit.locale,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              ' ' + LocaleKeys.appStrings_delete.locale,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}
