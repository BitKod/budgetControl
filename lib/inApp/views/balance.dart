import 'package:budgetControl/core/init/locale_keys.g.dart';
import 'package:budgetControl/core/init/string_extensions.dart';
import 'package:budgetControl/core/view/base/base_state.dart';
import 'package:budgetControl/core/view/widget/loading/loading.dart';
import 'package:budgetControl/inApp/models/expense.dart';
import 'package:budgetControl/inApp/models/income.dart';
import 'package:budgetControl/inApp/services/auth.dart';
import 'package:budgetControl/inApp/services/database_expense.dart';
import 'package:budgetControl/inApp/services/database_income.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Balances extends StatefulWidget {
  const Balances({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BalancesState();
}

class _BalancesState extends BaseState<Balances> {
  final GlobalKey<ScaffoldState> _scaffoldKeyBalances =
      new GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();


  String userUid;

  List<Income> _incomes = [];
  List<Expense> _expenses = [];
  List _balances;

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

  String _bankName;
  String _periodMonth;
  String _periodYear;
  double _sumOfIncome = 0.0;
  double _sumOfExpense = 0.0;
  double _sumOfBalance = 0.0;

  // NONE USE ITEMS
  String _incomeType;
  String _expenseType;
  String _expenseInstrument;


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      key: _scaffoldKeyBalances,
      appBar: AppBar(
        title: Text(LocaleKeys.appStrings_balances.locale),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseIncomeService().getFilteredIncomes(
            userUid, _bankName, _incomeType, _periodMonth, _periodYear),
        builder: (context, snapshotIncome) {
          switch (snapshotIncome.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Loading();
            default:
              _incomes = snapshotIncome.data.documents.map((doc) {
                return Income.fromFirestore(doc);
              }).toList();
              for (var i = 0; i < _incomes.length; i++) {
                _sumOfIncome =
                    _sumOfIncome + double.parse(_incomes[i].incomeAmount);
              }
              return StreamBuilder<QuerySnapshot>(
                stream: DatabaseExpenseService().getFilteredExpenses(
                    userUid,
                    _bankName,
                    _expenseType,
                    _expenseInstrument,
                    _periodMonth,
                    _periodYear),
                builder: (context, snapshotExpense) {
                  switch (snapshotExpense.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Loading();
                    default:
                      _expenses = snapshotExpense.data.documents.map((doc) {
                        return Expense.fromFirestore(doc);
                      }).toList();
                      for (var i = 0; i < _expenses.length; i++) {
                        _sumOfExpense = _sumOfExpense +
                            double.parse(_expenses[i].expenseAmount);
                      }

                      _sumOfBalance = _sumOfIncome - _sumOfExpense;


                      _balances=new List.from(_incomes)..addAll(_expenses);
                     


                      return SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                      _sumOfBalance = 0.0;
                                      _sumOfIncome = 0.0;
                                      _sumOfExpense = 0.0;
                                    });
                                  }),
                                  items: _balances
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
                                    _periodMonth = null;
                                    _periodYear = null;
                                    _sumOfBalance = 0.0;
                                    _sumOfIncome = 0.0;
                                    _sumOfExpense = 0.0;
                                  });
                                  _scaffoldKeyBalances.currentState
                                      .showSnackBar(
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
                                color: Colors.blueGrey,
                                height: dynamicHeight(0.05),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      LocaleKeys.appStrings_sumOfBalance.locale+' ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _sumOfBalance.toStringAsFixed(2),
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
                              itemCount: snapshotIncome.data.documents.length,
                              itemBuilder: (context, index) {
                                return Card(
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
                                );
                              },
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
                              itemCount: snapshotExpense.data.documents.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  color: currentTheme.errorColor,
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
                                );
                              },
                            ),
                          ],
                        ),
                      );
                  }
                },
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
                _sumOfBalance = 0.0;
                _sumOfIncome = 0.0;
                _sumOfExpense = 0.0;
              });
              _scaffoldKeyBalances.currentState.showSnackBar(SnackBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                content: Text(
                    "$_periodMonth / $_periodYear"),
                duration: Duration(seconds: 1),
              ));
            }
          },
        );
      },
    );
  }
}
