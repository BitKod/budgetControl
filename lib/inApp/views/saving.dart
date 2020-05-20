import 'package:budgetControl/core/init/locale_keys.g.dart';
import 'package:budgetControl/core/init/string_extensions.dart';
import 'package:budgetControl/core/view/base/base_state.dart';
import 'package:budgetControl/core/view/widget/card/text_input_card.dart';
import 'package:budgetControl/core/view/widget/loading/loading.dart';
import 'package:budgetControl/inApp/models/bank.dart';
import 'package:budgetControl/inApp/models/saving.dart';
import 'package:budgetControl/inApp/services/database_saving.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Savings extends StatefulWidget {
  const Savings({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SavingsState();
}

class _SavingsState extends BaseState<Savings> {
  final GlobalKey<ScaffoldState> _scaffoldKeySavings =
      new GlobalKey<ScaffoldState>();

  List<Saving> _savings = [];

  initState() {
    getUserUid();
    getCurrency();
    super.initState();
  }

  getCurrency() async {
    double USD = await DatabaseSavingService().getCurrencyUSD();
    double EUR = await DatabaseSavingService().getCurrencyEUR();
    setState(
      () {
        _USD = USD;
        _EUR = EUR;
      },
    );
  }

  double _USD = 0.0;
  double _EUR = 0.0;

  String _bankName;
  String _savingType;
  String _savingDate;
  double _sumOfSaving = 0.0;
  double _sumOfUSD = 0.0;
  double _sumOfEUR = 0.0;
  double _balanceOfSavingUSD = 0.0;
  double _balanceOfSavingEUR = 0.0;

  final _savingFormKey = GlobalKey<FormState>();
  final _savingIdController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _savingTypeController = TextEditingController();
  final _savingAmountController = TextEditingController();
  final _savingCurrencyController = TextEditingController();
  final _savingDateController = TextEditingController();

  @override
  void dispose() {
    _savingIdController.dispose();
    _bankNameController.dispose();
    _savingTypeController.dispose();
    _savingAmountController.dispose();
    _savingCurrencyController.dispose();
    _savingDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _banks = Provider.of<List<Bank>>(context) ?? [];
    return Scaffold(
      key: _scaffoldKeySavings,
      appBar: AppBar(
        title: Text(LocaleKeys.appStrings_savings.locale),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseSavingService()
            .getFilteredSavings(userUid, _bankName, _savingType, _savingDate),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Loading();
            default:
              _savings = snapshot.data.documents.map((doc) {
                return Saving.fromFirestore(doc);
              }).toList();
              _sumOfSaving = 0.0;
              for (var i = 0; i < _savings.length; i++) {
                if (_savings[i].savingType == 'USD') {
                  _sumOfUSD =
                      _sumOfUSD + double.parse(_savings[i].savingAmount);
                  _sumOfSaving = _sumOfSaving +
                      (double.parse(_savings[i].savingAmount) * _USD);
                  _balanceOfSavingUSD = _balanceOfSavingUSD +
                      double.parse(_savings[i].savingCurrency) *
                          double.parse(_savings[i].savingAmount);
                } else if (_savings[i].savingType == 'EUR') {
                  _sumOfEUR =
                      _sumOfEUR + double.parse(_savings[i].savingAmount);
                  _sumOfSaving = _sumOfSaving +
                      (double.parse(_savings[i].savingAmount) * _EUR);
                  _balanceOfSavingEUR = _balanceOfSavingEUR +
                      double.parse(_savings[i].savingCurrency) *
                          double.parse(_savings[i].savingAmount);
                }
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
                          items: _savings
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
                          value: _savingType,
                          hint: Text(LocaleKeys.appStrings_savingType.locale),
                          onChanged: ((String newValue) {
                            setState(() {
                              _savingType = newValue;
                            });
                          }),
                          items: _savings
                              .map((f) => f.savingType)
                              .toSet()
                              .toList()
                              .map(
                                (savingType) => DropdownMenuItem<String>(
                                  value: savingType,
                                  child: Text(savingType),
                                ),
                              )
                              .toList(),
                        ),
                        RaisedButton(
                          child: Text(LocaleKeys.appStrings_selectDate.locale),
                          color: currentTheme.primaryColor,
                          textColor: Colors.white,
                          onPressed: () async {
                            _savingDateController.text = await _selectDate();
                            setState(() {
                              _savingDate = _savingDateController.text;
                            });
                            _scaffoldKeySavings.currentState.showSnackBar(
                              SnackBar(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                content: Text("${_savingDate}"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
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
                            _savingType = null;
                            _savingDate = null;
                          });
                          _scaffoldKeySavings.currentState.showSnackBar(
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
                        color: Colors.blueGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  LocaleKeys.appStrings_eurCurrencyIs.locale,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _EUR.toStringAsFixed(2),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  LocaleKeys.appStrings_usdCurrencyIs.locale,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _USD.toStringAsFixed(2),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  LocaleKeys.appStrings_sumOfSaving.locale +
                                      ' ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _sumOfSaving.toStringAsFixed(2),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  LocaleKeys.appStrings_eurBalanceIs.locale,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  (_balanceOfSavingEUR / _sumOfEUR)
                                      .toStringAsFixed(2),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  LocaleKeys.appStrings_usdBalanceIs.locale,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  (_balanceOfSavingUSD / _sumOfUSD)
                                      .toStringAsFixed(2),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
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
                        Saving _saving = _savings[index];
                        return Dismissible(
                          key: Key(_saving.id),
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
                                        _savings[index].bankName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        _savings[index].savingAmount,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            _savings[index].savingType,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            _savings[index].savingCurrency,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
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
                                          "${LocaleKeys.appStrings_deleteConfirmation.locale} ${_savings[index].bankName}?"),
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
                                                    await DatabaseSavingService()
                                                        .deleteSaving(
                                                  userUid,
                                                  _saving.id,
                                                );
                                                if (result != null) {
                                                  Navigator.pop(context);
                                                  _scaffoldKeySavings
                                                      .currentState
                                                      .showSnackBar(SnackBar(
                                                    content: Text(LocaleKeys
                                                        .appStrings_savingDeleted
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
                              _savingIdController.text = _saving.id;
                              _bankNameController.text = _saving.bankName;
                              _savingTypeController.text = _saving.savingType;
                              _savingAmountController.text =
                                  _saving.savingAmount;
                              _savingCurrencyController.text =
                                  _saving.savingCurrency;
                              _savingDateController.text = _saving.savingDate;
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
                                      LocaleKeys.appStrings_editSaving.locale),
                                  children: <Widget>[
                                    loading
                                        ? Loading()
                                        : SingleChildScrollView(
                                            child: Form(
                                              key: _savingFormKey,
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
                                                          if (_savingFormKey
                                                              .currentState
                                                              .validate()) {
                                                            setState(() =>
                                                                loading = true);
                                                            try {
                                                              dynamic result =
                                                                  await DatabaseSavingService()
                                                                      .editSaving(
                                                                userUid,
                                                                _savingIdController
                                                                    .text,
                                                                _bankNameController
                                                                    .text,
                                                                _savingTypeController
                                                                    .text,
                                                                _savingAmountController
                                                                    .text
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            ','),
                                                                        '.'),
                                                                _savingCurrencyController
                                                                    .text,
                                                                _savingDateController
                                                                    .text,
                                                              );
                                                              if (result !=
                                                                  null) {
                                                                setState(() =>
                                                                    loading =
                                                                        false);
                                                                Navigator.pop(
                                                                    context);
                                                                _scaffoldKeySavings
                                                                    .currentState
                                                                    .showSnackBar(
                                                                        SnackBar(
                                                                  content: Text(
                                                                      LocaleKeys
                                                                          .appStrings_savingEdited
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
                                                    _getBankChipSaving(
                                                        _banks,
                                                        _bankNameController,
                                                        _savingTypeController),
                                                    SizedBox(
                                                        height: dynamicHeight(
                                                            0.01)),
                                                    TextInputCard(
                                                      TextFormField(
                                                        enabled: false,
                                                        decoration: appConstants
                                                            .textInputDecoration
                                                            .copyWith(
                                                                labelText: LocaleKeys
                                                                    .appStrings_savingType
                                                                    .locale),
                                                        controller:
                                                            _savingTypeController,
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return LocaleKeys
                                                                .appStrings_enterSavingType
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
                                                                    .appStrings_savingAmount
                                                                    .locale),
                                                        controller:
                                                            _savingAmountController,
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return LocaleKeys
                                                                .appStrings_enterSavingAmount
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
                                                                    .appStrings_savingCurrency
                                                                    .locale),
                                                        controller:
                                                            _savingCurrencyController,
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return LocaleKeys
                                                                .appStrings_enterSavingCurrency
                                                                .locale;
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        _savingDateController
                                                                .text =
                                                            await _selectDate();
                                                      },
                                                      child: IgnorePointer(
                                                        child:
                                                            new TextFormField(
                                                          decoration: appConstants
                                                              .textInputDecoration
                                                              .copyWith(
                                                                  labelText: LocaleKeys
                                                                      .appStrings_savingDate
                                                                      .locale),
                                                          controller:
                                                              _savingDateController,
                                                          validator: (value) {
                                                            if (value.isEmpty) {
                                                              return LocaleKeys
                                                                  .appStrings_enterSavingDate
                                                                  .locale;
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ),
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
                                  _scaffoldKeySavings.currentState.showSnackBar(
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
              _scaffoldKeySavings.currentState.showSnackBar(SnackBar(
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
}
