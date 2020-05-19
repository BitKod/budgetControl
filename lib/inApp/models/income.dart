import 'package:budgetControl/core/model/base_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Income extends BaseModel{
  Income({
    this.id,
    this.bankName,
    this.incomeType,
    this.incomeAmount,
    this.periodMonth,
    this.periodYear,
    this.createdAt,
    this.updatedAt,
  });

  Income.fromFirestore(DocumentSnapshot document)
      : id = document.documentID,
        bankName = document['bankName'],
        incomeType = document['incomeType'],
        incomeAmount = document['incomeAmount'],
        periodMonth = document['periodMonth'],
        periodYear = document['periodYear'],
        createdAt = document['createdAt'],
        updatedAt = document['updatedAt'];

  final String bankName;
  final Timestamp createdAt;
  final String id;
  final String incomeAmount;
  final String incomeType;
  final String periodMonth;
  final String periodYear;
  final Timestamp updatedAt;

  @override
  fromJson(Map<String, Object> json) {
    throw UnimplementedError();
  }

  @override
  Map<String, Object> toJson() {
    throw UnimplementedError();
  }
}