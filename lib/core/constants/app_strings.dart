class AppStrings {

    // declaring app strings

  static AppStrings _instance = AppStrings._init();
  static AppStrings get instance => _instance;
  AppStrings._init();

///////////////////////////////////////////////////
///can be used for language inputs
  String errorCYI = 'Check your information';
  String budgetControlApp = "Budget Control";
 
  //welcome.dart
  String welcomeTitle = "Welcome to Budget Control";
  String email = 'email';
  String enterEmail = 'Please enter an email';
  String enterValidEmail = 'Please enter an valid email';
  String password = 'password';
  String enterPassword = 'Please enter a password';
  String confirmPassword = 'confirm password';
  String confirmPasswordMatch = 'Password is not matching';
  String name = 'name';
  String enterName = 'Please enter a name';
  String login = 'Login';
  String register = 'Register';

  //dashboard.dart
  String dashboard='Dashboard';
  List dashboardItems = [
    'balance',
    'incomes',
    'expenses',
    'savings',
  ];

  //profile.dart
  String profilePicUpload = 'Profile Picture Uploaded';
  String profile = 'Profile';
  String signOut = 'Sign Out';
  String profileUpdated = 'Profile Updated';
  String update = 'Update';
  String cancel = 'Cancel';
  String uploadPicture = 'Upload Picture';
  String darkModeSwitch='Dark Mode';
  String languageSwitch='Turkish';

  //dataInput.dart

  List dataInputItems = [
    'Banks',
    'Credit Cards',
    'Invoices',
    'Fixed Expenses',
  ];

  String dataInput = 'Data Input';
  String bankName = 'bank name';
  String enterbankName = 'Please enter a Bank Name';
  String accountType = 'account type';
  String enterAccountType = 'Please enter a Account Type';
  String owner = 'owner';
  String enterOwner = 'Please enter a Owner';
  String add = 'Add';
  String clearScreen = 'Clear Screen';
  String cardType = 'card type';
  String enterCardType = 'Please enter a Card Type';
  String invoiceType = 'invoice type';
  String enterInvoiceType = 'Please enter a Invoice Type';
  String paymentInstrument = 'payment instrument';
  String enterPaymentInstrument = 'Please enter a Payment Instrument';
  String fixedExpenseType = 'fixed expense type';
  String enterFixedExpenseType = 'Please enter a Fixed Expense Type';
  String details = 'details';
  String enterDetails = 'Please enter Details';

  //operation.dart
  List<String> expenseTypesList = [
    'Installment',
    'Fixed Expense',
    'Invoice',
    'Other'
  ];

  String incomes = 'Incomes';
  String expenses = 'Expenses';
  String savings = 'Savings';
  String operations = 'Operations';
  String selectDate = 'Select Date';
  String incomeType = 'income type';
  String enterIncomeType = 'Please enter a Income Type';
  String incomeAmount = 'income amount';
  String enterIncomeAmount = 'Please enter a Income Amount';
  String periodMonth = 'period month';
  String enterPeriodMonth = 'Please enter the month';
  String periodYear = 'period year';
  String enterPeriodYear = 'Please enter the year';
  String operationCompleted = 'Operation completed';
  String expenseType = 'expense type';
  String enterExpenseType = 'Please enter a Expense Type';
  String expenseAmount = 'expense amount';
  String enterExpenseAmount = 'Please enter a Expense Amount';
  String installmentPeriod = 'installment period';
  String enterInstallmentPeriod = 'Please enter Installment Period';
  String expenseInstrument = 'expense instrument';
  String enterExpenseInstrument = 'Please enter a Expense Instrument';
  String expenseDetail = 'expense detail';
  String enterExpenseDetail = 'Please enter a Expense Detail';
  String savingType = 'saving type';
  String enterSavingType = 'Please enter a Saving Type';
  String savingAmount = 'saving amount';
  String enterSavingAmount = 'Please enter a Saving Amount';
  String savingCurrency = 'saving currency';
  String enterSavingCurrency = 'Please enter Saving Currency';
  String savingDate = 'saving date';
  String enterSavingDate = 'Please enter Saving date';

//balance.dart
  String balances = 'Balances';
  String clearFilters = 'Clear Filters';
  String filtersCleared = 'All filters cleared';
  String sumOfBalance = 'Sum of your balanced budget is';

//income.dart
  String sumOfIncome = 'Sum of your income is';
  String deleteConfirmation = 'Are you sure you want to delete';
  String delete = 'Delete';
  String incomeDeleted = 'Income Deleted';
  String editIncome = 'Edit Income';
  String edit = 'Edit';
  String incomeEdited = 'Income Edited';

//expense.dart
  String sumOfExpense = 'Sum of your expense is';
  String expenseDeleted = 'Expense Deleted';
  String editExpense = 'Edit Expense';
  String expenseEdited = 'Expense Edited';

//saving.dart
  String eurCurrencyIs='EUR Currency is ';
  String usdCurrencyIs='USD Currency is ';
  String sumOfSaving = 'Sum of your saving is';
  String eurBalanceIs='EUR Balance is ';
  String usdBalanceIs='USD Balance is ';
  String savingDeleted = 'Saving Deleted';
  String editSaving = 'Edit Saving';
  String savingEdited = 'Saving Edited';





}
