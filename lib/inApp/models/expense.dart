import 'package:budgetControl/core/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense extends BaseModel{
  final String id;
  final String bankName;
  final String expenseType;
  final String expenseAmount;
  final String installmentPeriod;
  final String expenseInstrument;
  final String expenseDetail;
  final String periodMonth;
  final String periodYear;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Expense(
    this.installmentPeriod,
    {
    this.id,
    this.bankName,
    this.expenseType,
    this.expenseAmount,
    this.expenseInstrument,
    this.expenseDetail,
    this.periodMonth,
    this.periodYear,
    this.createdAt,
    this.updatedAt,
  });

  Expense.fromFirestore(DocumentSnapshot document)
      : id = document.documentID,
        bankName = document['bankName'],
        expenseType = document['expenseType'],
        expenseAmount = document['expenseAmount'],
        installmentPeriod = document['installmentPeriod'],
        expenseInstrument = document['expenseInstrument'],
        expenseDetail = document['expenseDetail'],
        periodMonth = document['periodMonth'],
        periodYear = document['periodYear'],
        createdAt = document['createdAt'],
        updatedAt = document['updatedAt'];

  @override
  fromJson(Map<String, Object> json) {
    throw UnimplementedError();
  }

  @override
  Map<String, Object> toJson() {
    throw UnimplementedError();
  }
}