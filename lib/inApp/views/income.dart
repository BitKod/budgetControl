import 'package:budgetControl/core/init/locale_keys.g.dart';
import 'package:budgetControl/core/init/string_extensions.dart';
import 'package:budgetControl/core/view/base/base_state.dart';
import 'package:budgetControl/core/view/widget/card/text_input_card.dart';
import 'package:budgetControl/core/view/widget/loading/loading.dart';
import 'package:budgetControl/inApp/models/bank.dart';
import 'package:budgetControl/inApp/models/income.dart';
import 'package:budgetControl/inApp/services/database_income.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

class Incomes extends StatefulWidget {
  const Incomes({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IncomesState();
}

class _IncomesState extends BaseState<Incomes> {

  final GlobalKey<ScaffoldState> _scaffoldKeyIncomes = new GlobalKey<ScaffoldState>();

  List<Income> _incomes = [];

  initState() {
    getUserUid();
    super.initState();
  }

  String _bankName;
  String _incomeType;
  String _periodMonth;
  String _periodYear;
  double _sumOfIncome = 0.0;

  final _incomeFormKey = GlobalKey<FormState>();
  final _incomeIdController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _incomeTypeController = TextEditingController();
  final _incomeAmountController = TextEditingController();
  final _periodMonthController = TextEditingController();
  final _periodYearController = TextEditingController();

  @override
  void dispose() {
    _incomeIdController.dispose();
    _bankNameController.dispose();
    _incomeTypeController.dispose();
    _incomeAmountController.dispose();
    _periodMonthController.dispose();
    _periodYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _banks = Provider.of<List<Bank>>(context) ?? [];
    return Scaffold(
      key: _scaffoldKeyIncomes,
      appBar: AppBar(
        title: Text(LocaleKeys.appStrings_incomes.locale),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseIncomeService().getFilteredIncomes(
            userUid, _bankName, _incomeType, _periodMonth, _periodYear),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Loading();
            default:
              _incomes = snapshot.data.documents.map((doc) {
                return Income.fromFirestore(doc);
              }).toList();
              _sumOfIncome = 0.0;
              for (var i = 0; i < _incomes.length; i++) {
                _sumOfIncome =
                    _sumOfIncome + double.parse(_incomes[i].incomeAmount);
              }
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                          items: _incomes
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
                        DropdownButton(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentTheme.primaryColorDark,
                          ),
                          value: _incomeType,
                          hint: Text(LocaleKeys.appStrings_incomeType.locale),
                          onChanged: ((String newValue) {
                            setState(() {
                              _incomeType = newValue;
                            });
                          }),
                          items: _incomes
                              .map((f) => f.incomeType)
                              .toSet()
                              .toList()
                              .map(
                                (incomeType) => DropdownMenuItem<String>(
                                  value: incomeType,
                                  child: Text(incomeType),
                                ),
                              )
                              .toList(),
                        ),
                        _getMonthYear(),
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
                            _incomeType = null;
                            _periodMonth = null;
                            _periodYear = null;
                          });
                          _scaffoldKeyIncomes.currentState.showSnackBar(
                            SnackBar(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              content: Text(LocaleKeys.appStrings_filtersCleared.locale),
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
                              LocaleKeys.appStrings_sumOfIncome.locale,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _sumOfIncome.toStringAsFixed(2),
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
                        Income _income = _incomes[index];
                        return Dismissible(
                          key: Key(_income.id),
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
                                        _incomes[index].bankName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _incomes[index].incomeAmount,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Text(
                                        _incomes[index].incomeType,
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
                                          "${LocaleKeys.appStrings_deleteConfirmation.locale} ${_incomes[index].bankName}?"),
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
                                              LocaleKeys.appStrings_delete.locale,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () async {
                                              try {
                                                dynamic result =
                                                    await DatabaseIncomeService()
                                                        .deleteIncome(
                                                  userUid,
                                                  _income.id,
                                                );
                                                if (result != null) {
                                                  
                                                  _scaffoldKeyIncomes
                                                      .currentState
                                                      .showSnackBar(SnackBar(
                                                    content:
                                                        Text(LocaleKeys.appStrings_incomeDeleted.locale),
                                                    duration:
                                                        Duration(seconds: 1),
                                                  ));
                                                  setState(
                                                      () => loading = false);
                                                  
                                                  Navigator.pop(context);
                                                } else {
                                                  setState(() => error =
                                                      LocaleKeys.appStrings_errorCYI.locale);
                                                }
                                              } catch (e) {
                                              }
                                            },),
                                      ],
                                    );
                                  },);
                            } else {
                              _incomeIdController.text = _income.id;
                              _bankNameController.text = _income.bankName;
                              _incomeTypeController.text = _income.incomeType;
                              _incomeAmountController.text =
                                  _income.incomeAmount;
                              _periodMonthController.text = _income.periodMonth;
                              _periodYearController.text = _income.periodYear;
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
                                  title: Text(LocaleKeys.appStrings_editIncome.locale),
                                  children: <Widget>[
                                    loading
                                        ? Loading()
                                        : SingleChildScrollView(
                                            child: Form(
                                              key: _incomeFormKey,
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
                                                        child: Text(LocaleKeys.appStrings_edit.locale),
                                                        color: currentTheme
                                                            .primaryColor,
                                                        textColor: Colors.white,
                                                        onPressed: () async {
                                                          if (_incomeFormKey
                                                              .currentState
                                                              .validate()) {
                                                            setState(() =>
                                                                loading = true);
                                                            try {
                                                              dynamic result =
                                                                  await DatabaseIncomeService()
                                                                      .editIncome(
                                                                userUid,
                                                                _incomeIdController
                                                                    .text,
                                                                _bankNameController
                                                                    .text,
                                                                _incomeTypeController
                                                                    .text,
                                                                _incomeAmountController
                                                                    .text
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            ','),
                                                                        '.'),
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
                                                                _scaffoldKeyIncomes
                                                                    .currentState
                                                                    .showSnackBar(
                                                                        SnackBar(
                                                                  content: Text(
                                                                      LocaleKeys.appStrings_incomeEdited.locale),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              1),
                                                                ));
                                                              } else {
                                                                setState(() =>
                                                                    error =
                                                                        LocaleKeys.appStrings_errorCYI.locale);
                                                                setState(() =>
                                                                    loading =
                                                                        false);
                                                              }
                                                            } catch (e) {
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    TextInputCard(
                                                      TextFormField(
                                                        enabled: false,
                                                        decoration: appConstants
                                                            .textInputDecoration
                                                            .copyWith(
                                                                labelText:
                                                                    LocaleKeys.appStrings_bankName.locale),
                                                        controller:
                                                            _bankNameController,
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return LocaleKeys.appStrings_enterbankName.locale;
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    _getBankChip(_banks,
                                                        _bankNameController),
                                                    SizedBox(
                                                        height: dynamicHeight(
                                                            0.01)),
                                                    TextInputCard(
                                                      TextFormField(
                                                        decoration: appConstants
                                                            .textInputDecoration
                                                            .copyWith(
                                                                labelText:
                                                                    LocaleKeys.appStrings_incomeType.locale),
                                                        controller:
                                                            _incomeTypeController,
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
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration: appConstants
                                                            .textInputDecoration
                                                            .copyWith(
                                                                labelText:
                                                                    LocaleKeys.appStrings_incomeAmount.locale),
                                                        controller:
                                                            _incomeAmountController,
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return LocaleKeys.appStrings_enterIncomeAmount.locale;
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
                                                                      labelText:
                                                                          LocaleKeys.appStrings_periodMonth.locale),
                                                              controller:
                                                                  _periodMonthController,
                                                              validator:
                                                                  (value) {
                                                                if (value
                                                                    .isEmpty) {
                                                                  return LocaleKeys.appStrings_enterPeriodMonth.locale;
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
                                                                      labelText:
                                                                          LocaleKeys.appStrings_periodYear.locale),
                                                              controller:
                                                                  _periodYearController,
                                                              validator:
                                                                  (value) {
                                                                if (value
                                                                    .isEmpty) {
                                                                  return LocaleKeys.appStrings_enterPeriodYear.locale;
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
                                                        height: dynamicHeight(
                                                            0.01)),
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
                                  _scaffoldKeyIncomes.currentState.showSnackBar(
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
              _scaffoldKeyIncomes.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                content: Text(
                    "${_periodMonth} / ${_periodYear}"),
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
              ' '+LocaleKeys.appStrings_edit.locale,
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
              ' '+LocaleKeys.appStrings_delete.locale,
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

  _getBankChip(_banks, _controller) {
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
              _banks[index].bankName + '/' + _banks[index].accountType,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _controller.text = _banks[index].bankName;
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
}
