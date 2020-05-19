import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:budgetControl/core/constants/app_constants.dart';
import 'package:budgetControl/core/theme/themeManager.dart';

import 'package:budgetControl/inApp/models/expense.dart';
import 'package:budgetControl/inApp/models/income.dart';
import 'package:budgetControl/inApp/models/saving.dart';
import 'package:budgetControl/inApp/models/bank.dart';
import 'package:budgetControl/inApp/models/credit_card.dart';
import 'package:budgetControl/inApp/models/fixed_expense.dart';
import 'package:budgetControl/inApp/models/invoice.dart';
import 'package:budgetControl/inApp/models/user.dart';

import 'package:budgetControl/inApp/services/database_expense.dart';
import 'package:budgetControl/inApp/services/database_income.dart';
import 'package:budgetControl/inApp/services/database_saving.dart';
import 'package:budgetControl/inApp/services/auth.dart';
import 'package:budgetControl/inApp/services/database_bank.dart';
import 'package:budgetControl/inApp/services/database_credit_card.dart';
import 'package:budgetControl/inApp/services/database_fixed_expense.dart';
import 'package:budgetControl/inApp/services/database_invoice.dart';

import 'package:budgetControl/inApp/views/balance.dart';
import 'package:budgetControl/inApp/views/expense.dart';
import 'package:budgetControl/inApp/views/income.dart';
import 'package:budgetControl/inApp/views/operation.dart';
import 'package:budgetControl/inApp/views/saving.dart';
import 'package:budgetControl/inApp/views/dashboard.dart';
import 'package:budgetControl/inApp/views/dataInput.dart';
import 'package:budgetControl/inApp/views/profile.dart';
import 'package:budgetControl/inApp/views/welcome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: AppConstants.SUPPORTED_LOCALE,
      path: AppConstants.LANG_PATH,
      //fallbackLocale: AppConstants.EN_LOCALE,
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuthenticated = false;
  FirebaseUser user;
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((changedUser) {
      setState(() {
        isAuthenticated = changedUser != null;
        user = changedUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>(
          create: (context) => FirebaseAuth.instance.onAuthStateChanged,
        ),
        StreamProvider<User>.value(value: AuthService().user),
        StreamProvider<List<Bank>>(
          create: (context) => DatabaseBankService(uid: user.uid).banks,
        ),
        StreamProvider<List<CreditCard>>(
          create: (context) =>
              DatabaseCreditCardService(uid: user.uid).creditCards,
        ),
        StreamProvider<List<Invoice>>(
          create: (context) => DatabaseInvoiceService(uid: user.uid).invoices,
        ),
        StreamProvider<List<FixedExpense>>(
          create: (context) =>
              DatabaseFixedExpenseService(uid: user.uid).fixedExpenses,
        ),
        StreamProvider<List<Saving>>(
          create: (context) => DatabaseSavingService(uid: user.uid).savings,
        ),
        StreamProvider<List<Income>>(
          create: (context) => DatabaseIncomeService(uid: user.uid).incomes,
        ),
        StreamProvider<List<Expense>>(
          create: (context) => DatabaseExpenseService(uid: user.uid).expenses,
        ),
        ChangeNotifierProvider<ThemeManager>(
          create: (context) => ThemeManager(),
        ),
      ],
      child: Consumer<ThemeManager>(builder: (context, settings, child) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          title: 'Budget Control',
          theme: settings.getTheme(),
          initialRoute: isAuthenticated ? '/dashboard' : '/welcome',
          routes: {
            '/welcome': (context) => Welcome(),
            '/dashboard': (context) => Dashboard(),
            '/datainput': (context) => DataInput(),
            '/operation': (context) => Operation(),
            '/incomes': (context) => Incomes(),
            '/expenses': (context) => Expenses(),
            '/savings': (context) => Savings(),
            '/balance': (context) => Balances(),
            '/profile': (context) => Profile(
                  userUid: isAuthenticated ? user.uid : '',
                ),
          },
        );
      }),
    );
  }
}
